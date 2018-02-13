# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
from pytz import timezone
import os
import urllib

js = '''$("{}").eq({}).attr('value', {})'''

def extract_file_name_from_path(fullFilePath):
    return os.path.split(fullFilePath)

def get_items_from_lot(items, lot_id):
    lot_items = []
    for item in items:
        if item['relatedLot'] == lot_id:
            lot_items.append(item)
    return lot_items

def get_webdriver():
    se2lib = BuiltIn().get_library_instance('Selenium2Library')
    return se2lib._current_browser()

def string_lower(string):
    return string.lower()

def string_studly(string):
    s_utf8 = string.decode('utf-8');
    s=s_utf8[0].upper()+s_utf8[1:];
    s.encode('utf-8')
    return s

def convert_date_for_compare(datestr):
    datestr = datetime.strptime(datestr, "%d.%m.%Y %H:%M").strftime("%Y-%m-%d %H:%M")
    date_obj = datetime.strptime(datestr, "%Y-%m-%d %H:%M")
    time_zone = timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime('%Y-%m-%d %H:%M:%S.%f%z')

def get_contract_end_date():
    timeNow = datetime.now()
    newTime = timeNow + timedelta(days=1)
    return newTime.strftime("%d-%m-%Y")

def convert_datetime_for_delivery(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%d-%m-%Y")
    return date_string

def convert_date_for_delivery(date):
    return datetime.strptime(date, '%d.%m.%Y').strftime('%d.%m.%Y %H:%M')

def convert_datetime_for_input(isodate):
    iso_dt = parse_date(isodate)
    date_string = iso_dt.strftime("%d-%m-%Y %H:%M")
    return date_string

def test_doc_type_to_option_type(string):
    return {
        u"qualification_documents": 'qualificationDocuments',
        u"eligibility_documents": 'eligibilityDocuments',
        u"financial_documents": 'financialDocuments'
    }.get(string,string)

def convert_method_type_to_controller(string):
    return {
            u"belowThreshold": 'below-threshold',
            u"aboveThresholdUa": 'above-threshold-ua',
            u"aboveThresholdEu": 'above-threshold-eu'
            }.get(string, string)


def convert_ubiz_string_to_common_string(string):
    return {
            u"ст. 35 п. 2 абз. 1": u"artContestIP" ,
            u"ст. 35 п. 2 абз. 2": u"noCompetition" ,
            u"ст. 35 п. 2 абз. 3": u"quick" ,
            u"ст. 35 п. 2 абз. 4": u"twiceUnsuccessful" ,
            u"ст. 35 п. 2 абз. 5": u"additionalPurchase" ,
            u"ст. 35 п. 2 абз. 6": u"additionalConstruction" ,
            u"ст. 35 п. 2 абз. 7": u"stateLegalServices" ,
            u"artContestIP": u"ст. 35 п. 2 абз. 1" ,
            u"noCompetition": u"ст. 35 п. 2 абз. 2" ,
            u"quick": u"ст. 35 п. 2 абз. 3" ,
            u"twiceUnsuccessful": u"ст. 35 п. 2 абз. 4" ,
            u"additionalPurchase": u"ст. 35 п. 2 абз. 5" ,
            u"additionalConstruction": u"ст. 35 п. 2 абз. 6" ,
            u"stateLegalServices": u"ст. 35 п. 2 абз. 7" ,
            u"Очікує рішення": u"active" ,
            u"Підписаний": u"active" ,
            u"Очікує підписання": u"pending" ,
            u"Кваліфіковано": u"active" ,
            u"Відмінена": u"cancelled" ,
            u"Відмова": u"unsuccessful" ,
            u"Кваліфікація": u"active.qualification" ,
            u"КВАЛІФІКАЦІЯ": u"active.qualification",
            u"Період уточнень": u"active.enquiries" ,
            u"ПЕРІОД УТОЧНЕНЬ": u"active.enquiries" ,
            u"Прийом заявок": u"active.tendering" ,
            u"ПРИЙОМ ПРОПОЗИЦІЙ": u"active.tendering",
            u"ПРЕКВАЛІФІКАЦІЯ": u'active.pre-qualification',
            u"Аукціон": u"active.auction" ,
            u"АУКЦІОН": u"active.auction" ,
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
            u"Код классификатора ДК 021:2015": u"ДК021",
            u"Код классификатора ДК 016:2010": u"ДКПП",
            u"з ПДВ": True,
            u"aboveThresholdUA": 'aboveThresholdUa',
            u"aboveThresholdEU": 'aboveThresholdEu',
            u"Лотом": 'lot',
            u"Тендером": 'tenderer',
            u"Предметом закупівлі": 'item',
            u"Недійсна пропозиція": 'invalid',
            u"очікує на кваліфікацію": u"pending",
            u"ПРЕКВАЛІФІКАЦІЯ (ПЕРІОД ОСКАРЖЕНЬ)" :u'active.pre-qualification.stand-still',
            u"Вимога": u"claim",
            u"флакон" : u"VI",
            u"resolved": True, 
            u"declined": False,
            u"resolution_resolved": u"Задоволено",
            u"resolution_declined": u"Не задоволено",
            u"resolution_invalid":  u"Відхилено",

    }.get(string, string)

def prepare_test_data(tender_data):
    tender_data.data.procuringEntity['name'] = u'ТОВ 4k-soft'
    tender_data.data.procuringEntity['identifier']['id'] = u'12345678'
    tender_data.data.procuringEntity['address']['streetAddress'] = u'Хрещатик, 1'
    tender_data.data.procuringEntity['address']['region'] = u'місто Київ'
    tender_data.data.procuringEntity['address']['locality'] = u'Киїі'
    tender_data.data.procuringEntity['address']['postalCode'] = u'12345'
    tender_data.data.procuringEntity['contactPoint']['telephone'] = u'0505554444'
    tender_data.data.procuringEntity['contactPoint']['faxNumber'] = u'0505554445'
    tender_data.data.procuringEntity['identifier']['legalName'] = u'ТОВАРИСТВО З ОБМЕЖЕНОЮ ВІДПОВІДАЛЬНІСТЮ 4k-soft'
    tender_data.data['items'][0]['deliveryDate']['startDate'] = convert_date_for_compare_without_time(tender_data.data['items'][0]['deliveryDate']['startDate'])
    tender_data.data['items'][0]['deliveryDate']['endDate'] = convert_date_for_compare_without_time(tender_data.data['items'][0]['deliveryDate']['endDate'])
    return tender_data

def download_document_from_url(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))

def get_percent(value):
    value = value * 100
    return format(value, '.0f')
