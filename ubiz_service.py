# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn

js = '''$("{}").eq({}).attr('value', {})'''

def get_webdriver():
    se2lib = BuiltIn().get_library_instance('Selenium2Library')
    return se2lib._current_browser()

def set_hidden_val_by_jquery(selector, index, value):
    driver = get_webdriver()
    driver.execute_script(js.format(selector, index, value))


def get_tender_id_from_url(url):
    return url.split('/')[-1]


def set_hidden_cpv(index, value):
    return set_hidden_val_by_jquery('[name*="op_classification_id"]', index, value)


def set_hidden_dkpp(index, value):
    return set_hidden_val_by_jquery('[name*="op_additional_classification_ids"]', index, value)


def convert_datetime_for_delivery(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%Y-%m-%d %H:%M")
    return date_string


