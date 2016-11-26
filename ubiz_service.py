# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
from pytz import timezone
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


def convert_ubiz_string_to_common_string(string):
    return {
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
    u"Аукціон скасовано" : u"active",
    u"Не відбувся" : u"unsuccessful",
    u"Ліцензія" : u"financialLicense",
    u"Підписаний протокол" : u"auctionProtocol",
    u" - " : u""
    }.get(string, string)

def subtract_from_time(date_time, subtr_min, subtr_sec):
    sub = datetime.strptime(date_time, "%d.%m.%Y %H:%M")
    sub = (sub - timedelta(minutes=int(subtr_min),
                           seconds=int(subtr_sec)))
    return timezone('Europe/Kiev').localize(sub).strftime('%Y-%m-%dT%H:%M:%S.%f%z')

def procuring_entity_name(tender_data):
     tender_data.data.procuringEntity['name'] = u"ПАТ \"Прайм-Банк\""
     return tender_data

def join(l, separator):
    return separator.join(l)
