*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  ubiz_service.py


*** Variables ***
${locator.tenderId}                                            css=.info-tender-id
${locator.title}                                               xpath=//*[contains(@class, 'tender-title')]
${locator.description}                                         xpath=//*[@class='description-wrapper']
${locator.minimalStep.amount}                                  css=.info-step
${locator.procuringEntity.name}                                css=.procuring-entity-name

${locator.value.valueAddedTaxIncluded}                         css=.tax-included-budget
${locator.value.amount}                                        css=.info-budget
${locator.value.currency}                                      css=.budget-currency

${locator.tenderPeriod.startDate}                              css=.tender-period-start
${locator.tenderPeriod.endDate}                                css=.tender-period-end

${locator.enquiryPeriod.startDate}                             css=.enquiry-period-start
${locator.enquiryPeriod.endDate}                               css=.enquiry-period-end

${locator.items[0].deliveryAddress.streetAddress}              css=.address
${locator.items[0].deliveryAddress.locality}                   css=.locality
${locator.items[0].deliveryAddress.region}                     css=.region
${locator.items[0].deliveryAddress.postalCode}                 css=.postal_code
${locator.items[0].deliveryAddress.countryName}                css=.country
${locator.items[0].deliveryLocation.longitude}                 css=.delivery-location-longitude
${locator.items[0].deliveryLocation.latitude}                  css=.delivery-location-latitude
${locator.items[0].deliveryDate.endDate}                       css=.delivery-end-date
${locator.items[0].classification.id}                          css=.classification-id
${locator.items[0].classification.description}                 css=.classification-description
${locator.items[0].classification.scheme}                      css=.classification-scheme
${locator.items[0].additionalClassifications[0].id}            css=.classification-id-additional
${locator.items[0].additionalClassifications[0].description}   css=.classification-description-additional
${locator.items[0].additionalClassifications[0].scheme}        css=.classification-scheme-additional
${locator.items[0].unit.name}                                  css=.unit-name
${locator.items[0].quantity}                                   css=.item-quantity
${locator.items[0].description}                                css=.item-description

${locator.questions.url}                                       css=.question-link
${locator.questions[0].title}                                  css=.question-title
${locator.questions[0].description}                            css=.question-description
${locator.questions[0].date}                                   css=.question-date
${locator.questions[0].answer}                                 css=.question-answer
${locator.status}                                              css=.tender-current-status
${locator.auction_link}                                        css=.tender-auction-link

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  ${INITIAL_TENDER_DATA}=  Add_data_for_GUI_FrontEnds  ${INITIAL_TENDER_DATA}
  [return]   ${INITIAL_TENDER_DATA}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  Open Browser  ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  '${username}' != 'ubiz_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Element Is Visible  xpath=//*[contains(@class, 'btn-auth1')]
  Click Link    xpath=//*[contains(@class, 'btn-auth1')]
  Wait Until Page Contains Element   id=login_email
  Input text   id=login_email      ${USERS.users['${username}'].login}
  Input text   id=login_password      ${USERS.users['${username}'].password}
  Click Button   id=login_submit_button

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${tender_data}=  Add_data_for_GUI_FrontEnds  ${ARGUMENTS[1]}
  ${tender_data}=  procuring_entity_name  ${tender_data}

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

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Click Element                     xpath=//*[contains(@class, 'btn-add')]
  Wait Until Element Is Visible  id=submitBtn
  Input text    id=TenderForm_op_title                  ${title}
  Input text    id=TenderForm_op_description            ${description}
  ${budget}=    Convert To String    ${budget}
  Input text    id=TenderForm_op_value_amount                  ${budget}
  Click Element                     css=.tender-mode
  Click Element                     css=.value-added-tax
  ${step_rate}=    Convert To String    ${step_rate}

  Додати предмет   ${items[0]}   0
  Run Keyword if   '${mode}' == 'multi'   Додати багато предметів   items
  Sleep  3

  ${start_date}=    Get From Dictionary   ${tender_data.data.tenderPeriod}   startDate
  ${start_date}=    convert_datetime_for_delivery   ${start_date}

  ${end_date}=      Get From Dictionary   ${tender_data.data.tenderPeriod}   endDate
  ${end_date}=      convert_datetime_for_delivery   ${end_date}

  ${enquiry_start_date}=    Get From Dictionary   ${tender_data.data.enquiryPeriod}   startDate
  ${enquiry_start_date}=    convert_datetime_for_delivery   ${enquiry_start_date}

  ${enquiry_end_date}=      Get From Dictionary   ${tender_data.data.enquiryPeriod}   endDate
  ${enquiry_end_date}=      convert_datetime_for_delivery   ${enquiry_end_date}

  Input text    id=TenderForm_op_min_step_amount            ${step_rate}
  Input text    id=TenderForm_op_enquiry_period_start_date        ${enquiry_start_date}
  Input text    id=TenderForm_op_enquiry_period_end_date          ${enquiry_end_date}
  Input text    id=TenderForm_op_tender_period_start_date        ${start_date}
  Input text    id=TenderForm_op_tender_period_end_date          ${end_date}

  Click Element   id=submitBtn
  Wait Until Page Contains Element   css=.info-tender-id     30
  ${tender_UAid}=   Отримати інформацію про tenderId
  ${Ids}=   Convert To String   ${tender_UAid}
  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${ARGUMENTS[0]}   ${tender_UAid}
  Log  ${Ids}
  [return]  ${Ids}

Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${current_location}=      Get Location
  ${id}=    Get Substring   ${current_location}
  ${Ids}=   Create List     ${tender_UAid}   ${id}

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ...      ${ARGUMENTS[1]} ==  ${INDEX}
  ${description}=   Get From Dictionary   ${ARGUMENTS[0]}              description
  ${cpv_id}=        Get From Dictionary   ${ARGUMENTS[0].classification}              id
  ${dkpp_id}=       Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  ${unit}=          Get From Dictionary   ${ARGUMENTS[0].unit}    name
  ${quantity}=      Get From Dictionary   ${ARGUMENTS[0]}         quantity

  ${countryName}=     Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}     countryName
  ${region}=     Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}     region
  ${locality}=     Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}     locality
  ${postalCode}=     Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}     postalCode
  ${streetAddress}=    Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}     streetAddress
  ${deliveryEndDate}=   Get From Dictionary   ${ARGUMENTS[0].deliveryDate}        endDate

  Input text                         xpath=(//*[@id='items-wrapper'])//input[contains(@id, '_op_description')]  ${description}
  Input text                         xpath=(//*[@id='items-wrapper'])//input[contains(@id, '_op_quantity')]  ${quantity}
  ${unit}=   Convert To String   ${unit}
  Execute Javascript  setMySelectBox("_op_unit_id", "${unit}", ${ARGUMENTS[1]})
  Click Element                      css=.item-shipping
  Wait Until Page Contains    Адреси доставки
  Click Element                      css=.showAddForm
  Wait Until Element Is Visible  id=add_new_address
  Input text                         id=DeliveryAddress_city   ${locality}
  Input text                         id=DeliveryAddress_address   ${streetAddress}
  Input text                         id=DeliveryAddress_postalCode   ${postalCode}
  Execute Javascript  document.getElementById('DeliveryAddress_region_id').selectedIndex=1
  Click Element                      id=add_new_address
  Wait Until Element Is Visible    css=.delivery-date-start
  ${deliveryEndDate}=      convert_datetime_for_delivery   ${deliveryEndDate}
  Input text    xpath=(//*[contains(@class,'delivery-date-start')])[1+${ARGUMENTS[1]}]        ${deliveryEndDate}
  Input text    xpath=(//*[contains(@class,'delivery-date-end')])[1+${ARGUMENTS[1]}]          ${deliveryEndDate}
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
  Клацнути і дочекатися  id=search_form_subm_but   xpath=(//*[@class='tender-item-title'])[1]  5

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Log to Console  'tender search: ${ARGUMENTS[1]}'
  Selenium2Library.Switch browser   ${ARGUMENTS[0]}
  Go To  ${BROKERS['${broker}'].homepage}
  Wait Until Page Contains Element    id=TenderSearchForm_query    20
  Input Text    id=TenderSearchForm_query    ${ARGUMENTS[1]}
  ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout_on_wait} s  0 s  Шукати і знайти
  Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за ${timeout_on_wait} секунд
  Wait Until Page Contains Element    xpath=(//*[@class='tender-item-title'])[1]    20
  Click Element    xpath=(//*[@class='tender-item-title'])[1]
  Wait Until Page Contains    ${ARGUMENTS[1]}    60
  Capture Page Screenshot

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[2]}

  Wait Until Page Contains Element   id=tenderUpdate    30
  Click Element              id=tenderUpdate

  Wait Until Page Contains Element   id=addDocumentTender
  Click Element   id=addDocumentTender
  Choose File    xpath=(//*[@name='file'])    ${ARGUMENTS[1]}
  Click Element   id=submitBtn


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

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}

  Wait Until Page Contains Element    id=registerProposition    90
  Click Element               id=registerProposition
  Wait Until Page Contains          Реєстрація пропозиції по закупівлі    
  Input text    xpath=//input[contains(@id, '_op_value_amount')]                  ${bid}
  Click Element               id=t5-label
  Click Element               id=t6-label
  Click Element               id=createProposition
  Wait Until Page Contains Element    id=activateProposition    90
  Click Element               id=activateProposition

скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element    id=cancelProposition    60
  Click Element               id=cancelProposition

Змінити цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  amount
    ...    ${ARGUMENTS[3]} ==  amount.value

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element    id=editProposition

  Click Element               id=editProposition
  Wait Until Page Contains Element    id=updateProposition    90

  Clear Element Text      xpath=//input[contains(@id, '_op_value_amount')]
  Input text    xpath=//input[contains(@id, '_op_value_amount')]                  ${ARGUMENTS[3]}
  Click Element               id=updateProposition

Завантажити документ в ставку
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[2]}
  Wait Until Page Contains Element    id=editProposition

  Click Element               id=editProposition
  Wait Until Page Contains Element    id=updateProposition    90

  Click Element   xpath=(//a[contains(@data-url,'getBidDocumentForm')])
  Choose File    xpath=(//*[@name='file'])    ${ARGUMENTS[1]}
  Execute Javascript  setMySelectBox("_op_document_type", "Цінова пропозиція", 0)
  Click Element               id=updateProposition


Змінити документ в ставці
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}

  Click Element               id=editProposition
  Wait Until Page Contains Element    id=updateProposition    90

  Choose File    xpath=(//*[@name='file'])    ${ARGUMENTS[1]}
  Click Element               id=updateProposition


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
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   id=addQuestion
  Click Element                      id=addQuestion

  Wait Until Page Contains Element   id=TenderQuestionForm_op_title
  Wait Until Page Contains Element   id=askQuestion
  Input text                         id=TenderQuestionForm_op_title                 ${title}
  Input text                         id=TenderQuestionForm_op_description           ${description}
  Click Element                      id=askQuestion

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
  Wait Until Page Contains Element   css=.question-link
  Click Element    css=.question-link

  Wait Until Page Contains Element   id=addAnswer
  Input text                         id=TenderQuestionAnswerForm_op_answer            ${answer}
  Click Element                      id=addAnswer

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}

  Wait Until Page Contains Element   id=tenderUpdate
  Click Element              id=tenderUpdate
  Wait Until Page Contains Element   id=TenderForm_op_description

  ${description}=   Convert To String    новое описание тендера
  Input text    id=TenderForm_op_description            ${description}
  Click Element   id=submitBtn
  Capture Page Screenshot

додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  3
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

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати текст із поля і показати на сторінці   value.valueAddedTaxIncluded
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  ${return_value}=   Convert To Boolean   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.currency
  ${return_value}=   Отримати текст із поля і показати на сторінці   value.currency
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   join   ${return_value}   ' '
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   join   ${return_value}   ' '
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

Отримати інформацію про items[0].deliveryDate.endDate
  Click Element    css=.collapsible
  sleep  1
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].deliveryDate.endDate
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryLocation.latitude
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryLocation.longitude
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryAddress.countryName
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryAddress.postalCode
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryAddress.region
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryAddress.locality
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryAddress.streetAddress
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].classification.scheme
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].additionalClassifications[0].scheme
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].unit.name
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
  Click Element    css=.collapsible
  sleep  1
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].description
  [return]  ${return_value}

Отримати інформацію про questions[0].title
  Click Element    css=.question-link
  Wait Until Page Contains Element   css=.question-title
  ${return_value}=   Отримати текст із поля і показати на сторінці   questions[0].title
  [return]  ${return_value}

Отримати інформацію про questions[0].description
  ${return_value}=   Отримати текст із поля і показати на сторінці   questions[0].description
  [return]  ${return_value}

Отримати інформацію про questions[0].answer
  Click Element    css=.question-link
  Wait Until Page Contains Element   css=.question-title
  ${return_value}=   Отримати текст із поля і показати на сторінці   questions[0].answer
  [return]  ${return_value}

Отримати інформацію про questions[0].date
  ${return_value}=   Отримати текст із поля і показати на сторінці  questions[0].date
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].unit.name
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   join   ${return_value}   ' '
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  [return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].classification.description
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.description
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  [return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].description
  [return]  ${return_value}

Отримати інформацію про status
  ${return_value}=   Отримати текст із поля і показати на сторінці   status
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати посилання на аукціон
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}


Отримати посилання на аукціон для глядача
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${return_value} =    Get Element Attribute  xpath=//a[contains(@class, 'tender-auction-link')]@href
  [return]  ${return_value}

Отримати посилання на аукціон для учасника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${return_value} =    Get Element Attribute  xpath=//a[contains(@class, 'tender-auction-link')]@href
  [return]  ${return_value}

