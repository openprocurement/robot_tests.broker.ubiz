# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
import os
import urllib


def get_library():
    return BuiltIn().get_library_instance('Selenium2Library')


def get_webdriver_instance():
    return get_library()._current_browser()

def get_cur_date():
    dnow = datetime.now()
    return dnow.strftime('%Y-%m-%d %H:%M')

def convert_datetime_for_delivery(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%Y-%m-%d %H:%M")
    return date_string
def concat(val1,val2):
    return val1+val2

def create_question_id(field,prefix):
    return 'q_'+field+ '_' + prefix

def get_download_file_path():
    return os.path.join(os.getcwd(), 'test_output')

def convert_ubiz_string_to_common_string(string):
    return {
    u"кілограми": u"кілограм",
    u"кг.": u"кілограми",
    u"кг": u"кілограми",
    u"MTK":u"метри квадратні",
    u"Право вимоги": u"dgfFinancialAssets",
    u"Майно банку": u"dgfOtherAssets",
    u"грн.": u"UAH",
    u"грн": u"UAH",
    u" з ПДВ": True,
    u"послуга":"E48",
    u"Картонки": u"Картонні коробки",
    u"Період уточнень/пропозицій": u"active.tendering",
    u"Період аукціону": u"active.auction",
    u"Пропозиції розглянуто": u"active.awarded",
    u"Період кваліфікації": u"active.qualification",
    u"Завершений": u"complete",
    u"Скасований": u"cancelled",
    }.get(string, string)

def convert_date_for_compare(datestr):
    return datetime.strptime(datestr, "%d.%m.%Y %H:%M").strftime("%Y-%m-%d %H:%M")

def convert_date_for_compare_full(datestr):
    return datetime.strptime(datestr, "%d.%m.%Y %H:%M").strftime("%Y-%m-%d %H:%M:%S.0+03:00")

def subtract_from_time(date_time, subtr_min, subtr_sec):
    sub = datetime.strptime(date_time, "%d.%m.%Y %H:%M")
    sub = (sub - timedelta(minutes=int(subtr_min), seconds=int(subtr_sec))).isoformat()
    return str(sub) + '.000000+03:00'


def procuring_entity_name(tender_data):
    tender_data.data.procuringEntity['name'] = u"ПАТ \"Прайм-Банк\""
    return tender_data


def split_take_item(value, separator, index):
    return value.split(separator)[int(index)]


def split_take_slice(value, separator, _from=None, to=None):
    l = value.split(separator)
    if to:
        l = l[:int(to)]
    if _from:
        l = l[int(_from):]
    return l


def join(l, separator):
    return separator.join(l)


def get_invisible_text(locator):
    element = get_library()._element_find(locator, False, True)
    return element.attribute('innerText')


def get_text_excluding_children(locator):
    element = get_library()._element_find(locator, False, True)
    text = get_webdriver_instance().execute_script("""
    return jQuery(arguments[0]).contents().filter(function() {
        return this.nodeType == Node.TEXT_NODE;
    }).text();
    """, element)
    return text.strip()
