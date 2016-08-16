# -*- coding: utf-8 -
from iso8601 import parse_date
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from robot.output import librarylogger

def get_library():
    return BuiltIn().get_library_instance('Selenium2Library')


def get_webdriver_instance():
    return get_library()._current_browser()


def convert_datetime_for_delivery(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%Y-%m-%d %H:%M")
    return date_string

def convert_ubiz_string_to_common_string(string):
    return {
        u"кілограми": u"кілограм",
        u"кг.": u"кілограми",
        u"грн.": u"UAH",
        u" з ПДВ": True,
        u"Картонки": u"Картонні коробки",
        u"Період уточнень": u"active.enquiries",
	u"Прийом заявок" :u"active.tendering",
        u"Прийом пропозицій": u"active.tendering",
        u"Аукціон": u"active.auction",
    }.get(string, string)


def convert_date_for_compare(datestr):
    return datetime.strptime(datestr, "%d.%m.%Y %H:%M").strftime("%Y-%m-%d %H:%M")


def procuring_entity_name(tender_data):
    tender_data.data.procuringEntity['name'] = u"4k-soft"
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
