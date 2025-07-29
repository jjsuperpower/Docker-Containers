import json
import os
import logging
import time

import requests

"""
Author: Jonathan Sanderson
Date: 2022-10 
LICENSE: BSD 3-Clause License

This is a modified script from https://github.com/porkbundomains/porkbun-dynamic-dns-python
because I didn't like their code and I wanted to use docker :)
"""


class PorkBunDDNS:
    """
    A class to interact with the Porkbun DNS API for dynamic DNS updates.

    This class provides methods to retrieve, delete, and create DNS records,
    as well as to fetch the current public IP address using the Porkbun API.
    """

    def __init__(self, config: dict, logger: logging.Logger):
        """
        Initialize the PorkBun_DDNS instance.

        Args:
            config (dict): API configuration dictionary.
            logger (logging.Logger): Logger instance for logging messages.
        """

        self.api_config = config
        self.logger = logger

    def get_records(self, root_domain):
        """
        Retrieve all DNS records for the specified root domain.

        Args:
            root_domain (str): The root domain to retrieve records for.

        Returns:
            dict: The response from the Porkbun API containing DNS records.

        Raises:
            Exception: If the API returns an error status.
        """

        allRecords = json.loads(
            requests.post(
                self.api_config['endpoint'] + '/dns/retrieve/' + root_domain, data=json.dumps(self.api_config)
            ).text
        )
        self.logger.debug(f'All records: {allRecords}')

        if allRecords['status'] == 'ERROR':
            self.logger.error(
                'Error getting domain. Check to make sure you specified the correct domain, and that API access has been switched on for this domain.'
            )
            raise Exception()

        return allRecords

    def get_my_ip(self):
        """
        Retrieve the current public IP address as seen by the Porkbun API.

        Returns:
            str: The public IP address.
        """

        ping = json.loads(requests.post(self.api_config['endpoint'] + '/ping/', data=json.dumps(self.api_config)).text)
        self.logger.debug(f'Ping: {ping}')

        return ping['yourIp']

    def delete_record(self, root_domain, sub_domain):
        """
        Delete existing A, ALIAS, or CNAME records for the given domain.

        Args:
            root_domain (str): The root domain.
            sub_domain (str): The subdomain to delete records for.
        """

        if sub_domain == '':
            domain = root_domain
        else:
            domain = sub_domain + '.' + root_domain

        for i in self.get_records(root_domain)['records']:
            if i['name'] == domain and (i['type'] == 'A' or i['type'] == 'ALIAS' or i['type'] == 'CNAME'):
                self.logger.debug('Deleting existing ' + i['type'] + ' Record')

                deleteRecord = json.loads(
                    requests.post(
                        self.api_config['endpoint'] + '/dns/delete/' + root_domain + '/' + i['id'],
                        data=json.dumps(self.api_config),
                    ).text
                )
                self.logger.debug(f'Deleted record: {deleteRecord}')

    def create_record(self, root_domain, sub_domain, ip=None):
        """
        Create a new A record for the specified domain and IP address.

        Args:
            root_domain (str): The root domain.
            sub_domain (str): The subdomain to create the record for.
            ip (str, optional): The IP address to set. If None, uses the current public IP.

        Returns:
            dict: The response from the Porkbun API after creating the record.
        """

        if ip is None:
            ip = self.get_my_ip()

        if sub_domain == '':
            domain = root_domain
        else:
            domain = sub_domain + '.' + root_domain

        self.logger.info(f'Updating {domain} with {ip}')

        createObj = self.api_config.copy()
        createObj.update({'name': sub_domain, 'type': 'A', 'content': ip, 'ttl': 300})
        self.logger.debug(f'Created object: {createObj}')

        self.logger.debug('Created record: ' + domain + ' with answer of ' + ip)
        create = json.loads(
            requests.post(self.api_config['endpoint'] + '/dns/create/' + root_domain, data=json.dumps(createObj)).text
        )
        self.logger.debug(f'Created record: {create}')

        if create['status'] == 'ERROR':
            self.logger.error('Error creating record')
        else:
            self.logger.info(create['status'])

        return create


def get_env():
    # set default values
    config = {}
    api_config = {}
    api_config['endpoint'] = 'https://api-ipv4.porkbun.com/api/json/v3'

    config['domains_file'] = 'data/domains.txt'
    config['interval'] = 60  # in minutes
    config['log_level'] = 'INFO'

    # read in enviroment variables
    if os.environ.get('endpoint') is not None:
        api_config['endpoint'] = os.environ['endpoint']

    if os.environ.get('apikey') is not None:
        api_config['apikey'] = os.environ['apikey']
    else:
        raise Exception('API Key is required')

    if os.environ.get('secretapikey') is not None:
        api_config['secretapikey'] = os.environ['secretapikey']
    else:
        raise Exception('Secret API Key is required')

    if os.environ.get('domain_file') is not None:
        config['domains_file'] = os.environ['domains_file']

    if os.environ.get('interval') is not None:
        config['interval'] = int(os.environ['interval'])

    if os.environ.get('log_level') is not None:
        config['log_level'] = os.environ['log_level']

    return config, api_config


# reqires opened file, not file name
# this uses generators so it looks bad, but is quite efficient
def parse_domains_file(file):
    # remove empty lines
    lines = (line.strip() for line in file if line.strip())

    # remove everything after a comment
    lines = (line.split('#')[0].strip() for line in lines)

    # replace commas with spaces
    lines = (line.replace(',', ' ') for line in lines)

    # replace all whitespace with a single space
    lines = (line.replace('\t', ' ') for line in lines)
    lines = (line.replace('\n', ' ') for line in lines)

    # reduce multiple spaces to one
    lines = (' '.join(line.split()) for line in lines)

    # use space as a delimiter
    lines = (line.split(' ') for line in lines)

    # remove empty lines
    lines = (line for line in lines if line[0] != '')

    # return [domain, None] if no static ip is specified
    lines = (line if len(line) == 2 else [line[0], None] for line in lines)

    # subdomain, rootdomain and ip
    lines = (
        {
            'root_domain': '.'.join(line[0].split('.')[-2:]),
            'subdomain': '.'.join(line[0].split('.')[:-2]),
            'domain': line[0],
            'ip': line[1],
        }
        for line in lines
    )

    return list(lines)


def main():
    config, api_config = get_env()
    logger = logging.getLogger('PB_DDNS')
    pb_ddns = PorkBunDDNS(api_config, logger)
    logging.basicConfig(level=config['log_level'], format='%(asctime)s %(levelname)s %(message)s')
    logging.info('Booting up')

    while True:
        # check if domains file exists
        if not os.path.isfile(config['domains_file']):
            logging.warning('Domains file does not exist')

        else:
            with open(config['domains_file']) as domains_file:
                domains = parse_domains_file(domains_file)
            logging.info('Read domains file')

            if len(domains) == 0:
                logging.warning('No domains to update')
            else:
                for domain in domains:
                    pb_ddns.delete_record(domain['root_domain'], domain['subdomain'])
                    pb_ddns.create_record(domain['root_domain'], domain['subdomain'], domain['ip'])

        if config['interval'] == 0:
            logging.info('Interval set to 0, exiting')
            break
        else:
            logging.info(f'Waiting {config["interval"]} minutes')
            time.sleep(config['interval'] * 60)


if __name__ == '__main__':
    main()
    logging.info('Shutting down')
