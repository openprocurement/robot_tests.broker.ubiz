*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  ubiz_service.py

*** Variables ***
${locator.tenderId}                                            xpath=//*[contains(@class, 'info-tender-id')]//*[@class='value']
${locator.title}                                               jquery=h3
${locator.description}                                         xpath=//*[@class='description-wrapper']
${locator.minimalStep.amount}                                  xpath=//*[contains(@class, 'info-min-step')]//*[@class='value']
${locator.procuringEntity.name}                                xpath=//*[@class='company-information-list-wrapper']/*[1]//span
${locator.value.amount}                                        xpath=//*[contains(@class, 'info-budget')]//*[@class='value']
${locator.tenderPeriod.startDate}                              xpath=//*[contains(@class, 'time-label-wrapper section3')]/*[3]//*[@class='date-wrapper']/span
${locator.tenderPeriod.endDate}                                xpath=//*[contains(@class, 'time-label-wrapper section3')]/*[4]//*[@class='date-wrapper']/span
${locator.enquiryPeriod.startDate}                             xpath=//*[contains(@class, 'time-label-wrapper section3')]/*[1]//*[@class='date-wrapper']/span
${locator.enquiryPeriod.endDate}                               xpath=//*[contains(@class, 'time-label-wrapper section3')]/*[2]//*[@class='date-wrapper']/span
${locator.items[0].description}                                xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'description')]
${locator.items[0].classification.id}                          xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/span
#${locator.items[0].classification.description}                 xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/span
${locator.items[0].additionalClassifications[0].id}            xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][2]/span
#${locator.items[0].additionalClassifications[0].description}   xpath=(//*[contains(@class, 'panel-collapse')])[1]//*[@class='item-wrapper'][1]/span
#${locator.items[0].unit.code}                                  xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'quantity')]
${locator.items[0].quantity}                                   xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'quantity')]

#${locator.questions[0].title}                                  xpath=(//div[@class='col-sm-10']/span[@class='ng-binding'])[2]
#${locator.questions[0].description}                            xpath=(//div[@class='col-sm-10']/span[@class='ng-binding'])[3]
#${locator.questions[0].date}                                   xpath=(//div[@class='col-sm-10']/span[@class='ng-binding'])[1]
#${locator.questions[0].answer}                                 xpath=(//div[@textarea='question.answer']/pre[@class='ng-binding'])[1]

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  ${INITIAL_TENDER_DATA}=  prepare_test_tender_data
  ${INITIAL_TENDER_DATA}=  Add_data_for_GUI_FrontEnds  ${INITIAL_TENDER_DATA}
  [return]   ${INITIAL_TENDER_DATA}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
#  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Open Browser  ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  '${username}' != 'ubiz_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  #Page Should Contain Link    jquery=.btn-auth    180
  #Sleep    1
  Wait Until Element Is Visible  xpath=//*[contains(@class, 'btn-auth1')]  10
  Click Link    xpath=//*[contains(@class, 'btn-auth1')]
  Sleep    1
  Wait Until Page Contains Element   id=UserLoginForm_email   20
  Sleep  1
  Input text   id=UserLoginForm_email      ${USERS.users['${username}'].login}
#  Wait Until Page Contains Element   id=UserLoginForm_password   180
#  Sleep  1
  Input text   id=UserLoginForm_password      ${USERS.users['${username}'].password}
  Click Button   xpath=//*[@type='submit']
  Wait Until Page Contains          Закупівлі   20
  Go To  ${USERS.users['${username}'].homepage}

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${tender_data}=  Add_data_for_GUI_FrontEnds  ${ARGUMENTS[1]}
#  ${tender_data}=  procuring_entity_name  ${tender_data}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${title}=         Get From Dictionary   ${tender_data.data}               title
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ${budget}=        Get From Dictionary   ${tender_data.data.value}         amount
  ${step_rate}=     Get From Dictionary   ${tender_data.data.minimalStep}   amount
  ${items_description}=   Get From Dictionary   ${items[0]}         description
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${cpv}=           Get From Dictionary   ${items[0].classification}         id
  ${unit}=          Get From Dictionary   ${items[0].unit}                   name
  ${latitude}       Get From Dictionary   ${items[0].deliveryLocation}    latitude
  ${longitude}      Get From Dictionary   ${items[0].deliveryLocation}    longitude
  ${postalCode}    Get From Dictionary   ${items[0].deliveryAddress}     postalCode
  ${streetAddress}    Get From Dictionary   ${items[0].deliveryAddress}     streetAddress
  ${deliveryDate}   Get From Dictionary   ${items[0].deliveryDate}        endDate
  ${start_date}=    Get From Dictionary   ${tender_data.data.tenderPeriod}   startDate
  ${start_date}=    convert_datetime_for_delivery   ${start_date}
  ${end_date}=      Get From Dictionary   ${tender_data.data.tenderPeriod}   endDate
  ${end_date}=      convert_datetime_for_delivery   ${end_date}
  ${enquiry_start_date}=    Get From Dictionary   ${tender_data.data.enquiryPeriod}   startDate
  ${enquiry_start_date}=    convert_datetime_for_delivery   ${enquiry_start_date}
  ${enquiry_end_date}=      Get From Dictionary   ${tender_data.data.enquiryPeriod}   endDate
  ${enquiry_end_date}=      convert_datetime_for_delivery   ${enquiry_end_date}

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Go To                             ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Wait Until Page Contains          Закупівлі   10
  Sleep  1
  Click Element                     xpath=//*[contains(@class, 'btn-success')]
  Sleep  1
  Wait Until Page Contains          Створення закупівлі  10
  Input text    id=TenderForm_op_title                  ${title}
  Input text    id=TenderForm_op_description            ${description}
  Input text    id=TenderForm_op_value_amount                  ${budget}
  Click Element                     id=TenderForm_op_value_added_tax_included
  Input text    id=TenderForm_op_min_step_amount            ${step_rate}
  Input text    id=TenderForm_op_enquiry_period_start_date        ${enquiry_start_date}
  Input text    id=TenderForm_op_enquiry_period_end_date          ${enquiry_end_date}
  Input text    id=TenderForm_op_tender_period_start_date        ${start_date}
  Input text    id=TenderForm_op_tender_period_end_date          ${end_date}

  Додати предмет   ${items[0]}   0
  Run Keyword if   '${mode}' == 'multi'   Додати багато предметів   items
  Sleep  1
  Wait Until Page Contains Element   xpath=//*[@type='submit']
  Click Element   xpath=//*[@type='submit']
  Sleep  1
  Wait Until Page Contains   Закупівля успішно створена   10
  #Sleep   2
  ${tender_url}=    Get Element Attribute  xpath=(//*[@class='title-wrapper'])[1]/a@href
  Go To  ${tender_url}
  Sleep  1
  Wait Until Page Contains  Інформація про закупівлю
  #Sleep   5
  ${tender_UAid}=  Get Text  xpath=//*[contains(@class, 'info-tender-id')]//*[@class='value']
  #Log To Console  ${tender_UAid}
  ${Ids}=   Convert To String   ${tender_UAid}
  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${ARGUMENTS[0]}   ${tender_UAid}
  Log  ${Ids}
  [return]  ${Ids}

Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${current_location}=      Get Location
  ${id}=    Get Substring   ${current_location}   10
  ${Ids}=   Create List     ${tender_UAid}   ${id}

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ...      ${ARGUMENTS[1]} ==  ${INDEX}
  ${description}=   Get From Dictionary   ${ARGUMENTS[0].classification}              description
  ${cpv_id}=        Get From Dictionary   ${ARGUMENTS[0].classification}              id
  ${dkpp_id}=       Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  ${unit}=          Get From Dictionary   ${ARGUMENTS[0].unit}    name
  ${quantity}=      Get From Dictionary   ${ARGUMENTS[0]}         quantity
  Sleep  2
  Input text                         xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_description')]  ${description}
  Input text                         xpath=(//*[@data-type='item'])[last()]//input[contains(@id, '_op_quantity')]  ${quantity}
  Select From List By Label          xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_unit_id')]  ${unit}
# TO be debugged, impossible to select checkbox in this AJAX fancytree
#  Sleep  2
#  Click Element                      xpath=(//*[@data-type='item'])[last()]//button[contains(., 'CPV')]
#  Wait Until Element Is Visible      xpath=(//*[@data-type='item'])[last()]//h4[contains(., 'CPV')]
#  Sleep  1
#  Click Element                      xpath=(//*[@data-type='item'])[last()]//span[contains(span/b, '${cpv_id}')]/span[@class='fancytree-checkbox']
#  Sleep  1
#  Click Element                      xpath=(//*[@data-type='item'])[last()]//div[@class='form-group'][contains(.//input/@id, '_op_classification_id')]//button[contains(@class, 'js-submit-btn')]
#  Sleep  2
#  Click Element                      xpath=(//*[@data-type='item'])[last()]//button[contains(., 'ДКПП')]
#  Wait Until Element Is Visible      xpath=(//*[@data-type='item'])[last()]//h4[contains(., 'ДКПП')]
#  Sleep  1
#  Click Element                      xpath=(//*[@data-type='item'])[last()]//span[contains(span/b, '${dkpp_id}')]/span[@class='fancytree-checkbox']
#  Sleep  1
#  Click Element                      xpath=(//*[@data-type='item'])[last()]//div[@class='form-group'][contains(.//input/@id, '_op_additional_classification_ids')]//button[contains(@class, 'js-submit-btn')]
#  Sleep  1
   Execute Javascript  $('[name*="op_classification_id"]').eq(${ARGUMENTS[1]}).attr('value', '6272')
   Execute Javascript  $('[name*="op_additional_classification_ids"]').eq(${ARGUMENTS[1]}).attr('value', '11911')


Додати багато предметів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ${Items_length}=   Get Length   ${items}
  : FOR    ${INDEX}    IN RANGE    1    ${Items_length}
  \   Click Element   xpath=//*[contains(@class, 'js-items-add')]
  \   Додати предмет   ${items[${INDEX}]}   ${INDEX}

Клацнути і дочекатися
  [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
  [Documentation]
  ...      click_locator: Where to click
  ...      wanted_locator: What are we waiting for
  ...      timeout: Timeout
  Click Element  ${click_locator}
  Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
  Клацнути і дочекатися  xpath=//input[contains(./@class, 'btn-submit')]  xpath=(//*[@class='title-wrapper'])[1]  5

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Log to Console  'tender search'
  Selenium2Library.Switch browser   ${ARGUMENTS[0]}
  Go To  ${BROKERS['${broker}'].homepage}
  Wait Until Page Contains   Допорогові закупівлі України    20
#  sleep  1
  Wait Until Page Contains Element    id=TenderSearchForm_query    20
#  sleep  3
  Input Text    id=TenderSearchForm_query    ${ARGUMENTS[1]}
#  sleep  1
  ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout_on_wait} s  0 s  Шукати і знайти
  Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за ${timeout_on_wait} секунд
  sleep  3
  Wait Until Page Contains Element    xpath=(//*[@class='title-wrapper'])[1]    20
  sleep  1
  Click Element    xpath=(//*[@class='title-wrapper'])[1]/a
  Wait Until Page Contains    ${ARGUMENTS[1]}   60
  sleep  1
  Capture Page Screenshot

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${Complain}
  Fail   Тест не написаний

Подати скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${Complain}
  Fail  Не реалізований функціонал

порівняти скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Fail  Не реалізований функціонал

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=        Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains          Інформація про процедуру закупівлі    10
  Wait Until Page Contains Element          id=amount   10
  Input text    id=amount                  ${bid}
  Click Element                     xpath=//button[contains(@class, 'btn btn-success')][./text()='Реєстрація пропозиції']
  DEBUG
  Click Element               xpath=//div[@class='row']/button[@class='btn btn-success']

скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element               xpath=//button[@class='btn-sm btn-danger ng-isolate-scope']

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Log To Console  'refresh'
  ubiz.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Reload Page

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = question_data

  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   jquery=a[href^="#/addQuestion/"]   10
  Click Element                      jquery=a[href^="#/addQuestion/"]
  Wait Until Page Contains Element   id=title
  Input text                         id=title                 ${title}
  Input text                         id=description           ${description}
  Click Element                      xpath=//div[contains(@class, 'form-actions')]//button[@type='submit']

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//pre[@class='ng-binding'][text()='Додати відповідь']   10
  Click Element                      xpath=//pre[@class='ng-binding'][text()='Додати відповідь']
  Input text                         xpath=//div[@class='editable-controls form-group']//textarea            ${answer}
  Click Element                      xpath=//span[@class='editable-buttons']/button[@type='submit']

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  single
  ${tender_data}=   Add_data_for_GUI_FrontEnds   ${ADDITIONAL_DATA}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//a[@class='btn btn-primary ng-scope']   10
  Click Element              xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  Input text               id=description    ${description}
  Click Element              xpath=//button[@class='btn btn-info ng-isolate-scope']
  Capture Page Screenshot

додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  3
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  multi
  ${tender_data}=   Add_data_for_GUI_FrontEnds   ${ADDITIONAL_DATA}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Run keyword if   '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'   додати позицію
  Run keyword if   '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'   видалити позиції

додати позицію
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep  2
  Click Element                     xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]} +1
  \   Click Element   xpath=.//*[@id='myform']/tender-form/div/button
  \   Додати предмет   ${items[${INDEX}]}   ${INDEX}
  Sleep  2
  Click Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']
  Wait Until Page Contains    [ТЕСТУВАННЯ]   10

видалити позиції
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element                     xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]} +1
  \   Click Element   xpath=(//button[@class='btn btn-danger ng-scope'])[last()]
  \   Sleep  1
  Sleep  2
  Wait Until Page Contains Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']   10
  Click Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']
  Wait Until Page Contains    [ТЕСТУВАННЯ]   10

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  3
#  відмітити на сторінці поле з тендера   ${fieldname}   ${locator.${fieldname}}
  Wait Until Page Contains Element    ${locator.${fieldname}}    22
  Sleep  1
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Отримати текст із поля і показати на сторінці   title
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   Convert To Number   ${return_value.split(' ')[0]}
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".split(' ')[:-3])
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Відмітити на сторінці поле з тендера
  [Arguments]   ${fieldname}  ${locator}
  ${last_note_id}=  Add pointy note   ${locator}   Found ${fieldname}   width=200  position=bottom
  Align elements horizontally    ${locator}   ${last_note_id}
  sleep  1
  Remove element   ${last_note_id}

Отримати інформацію про tenderId
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderId
#  ${return_value}=   Get Substring  ${return_value}   10
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.startDate
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.endDate
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].description
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].description
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  [return]  ${' '.join(return_value.split()[:1]}

Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   ${return_value.split()[1]}
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  [return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].classification.description
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  ${return_value}=   Evaluate  " ".join('${return_value'.split()[:1])
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  [return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  ${return_value}=   Evaluate  " ".join('${return_value'.split()[:1])
  [return]  ${return_value[1]}

#Отримати інформацію про questions[0].title
#  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[0].title

#Отримати інформацію про questions[0].description
#  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[0].description

#Отримати інформацію про questions[0].date
#  ${return_value}=  Отримати текст із поля і показати на сторінці  questions[0].date
#  Run Keyword And Return  Change_date_to_month  ${return_value}

#Отримати інформацію про questions[0].answer
#  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[0].answer
