# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
from pytz import timezone
import os
import urllib

js = '''$("{}").eq({}).attr('value', {})'''


def convert_date_for_compare(datestr):
    return datetime.strptime(datestr, "%d.%m.%Y %H:%M").strftime("%Y-%m-%d %H:%M")

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
    periodd = timedelta(minutes=3)
    iso_dt = iso_dt + periodd
    date_string = iso_dt.strftime("%Y-%m-%d %H:%M")
    return date_string


def convert_ubiz_string_to_common_string(string):
    return {
            u"Кваліфікація": u"active.qualification" ,
            u"Період уточнень": u"active.enquiries" ,
            u"Прийом заявок": u"active.tendering" ,
            u"Аукціон": u"active.auction" ,
            u"пар": u"PR" ,
            u"літр" : u"LTR",
            u"набір" : u"SET",
            u"пачка" : u"RM",
            u"упаковка" :u"PK",
            u"пачок" : u"NMP",
            u"метри" : u"MTR",
            u"ящик" : u"BX",
            u"метри кубічні" : u"MTQ",
            u"рейс" : u"E54",
            u"тони" : u"TNE",
            u"метри квадратні" : u"MTK",
            u"кілометри" : u"KMT",
            u"штуки" : u"H87",
            u"місяць" : u"MON",
            u"лот" : u"LO",
            u"блок" : u"D64",
            u"гектар" : u"HAR",
            u"кілограми" : u"KGM",
            u"кг.": u"KGM",
            u"кг": u"KGM",
            u"Код классификатора ДК 021:2015": u"CPV",
            u"Код классификатора ДК 016:2010": u"ДКПП",
            u" з ПДВ": True

}.get(string, string)

def procuring_entity_name(tender_data):
     tender_data.data.procuringEntity['name'] = u"4k-soft"
     return tender_data

def join(l, separator):
     return separator.join(l)

