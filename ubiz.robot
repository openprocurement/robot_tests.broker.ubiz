*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  ubiz_service.py


*** Variables ***
${doc_index}                                                    0
${locator.auctionID}                                           id=auid
${locator.title}                                               id=op_name
${locator.status}                                              id=status
${locator.lotID}                                               id=lotID
${locator.dgfID}                                               id=dgfID
${locator.procedure}                                           id=procedure
${locator.eligibilityCriteria}                                 id=eligibilityCriteria
${locator.description}                                         id=op_description
${locator.minimalStep.amount}                                  id=min_step_value_amount
${locator.procuringEntity.name}                                id=procuring_entity_name
${locator.value.amount}                                        id=value_amount
${locator.value.currency}                                      id=value_currency
${locator.value.valueAddedTaxIncluded}                         id=value_pdf
${locator.tenderPeriod.startDate}                              css=.tender_period_start
${locator.tenderPeriod.endDate}                                css=.tender_period_end
${locator.auctionPeriod.startDate}                             css=.auction_period_start
${locator.auctionPeriod.endDate}                               css=.auction_period_end

${locator.qualificationPeriod.startDate}                        css=.qualification_period_start
${locator.qualificationPeriod.endDate}                          css=.qualification_period_end

${locator.enquiryPeriod.startDate}                             css=.enquiry_period_start
${locator.enquiryPeriod.endDate}                               css=.enquiry_period_end
${locator.items[0].description}                                css=.op_unit_description
${locator.items[0].classification.id}                          css=.op_class_id
${locator.items[0].classification.description}                 css=.op_class_name
${locator.items[0].classification.scheme}                      css=.classificator
${locator.items[0].unit.code}                                  css=.op_unit
${locator.items[0].quantity}                                   css=.op_quantity
${locator.mybid}                                               id=last_bid
${locator.questions[0].title}                                  css=.q_title_0
${locator.questions[0].description}                            css=.q_description_0
${locator.questions[0].date}                                   css=.q_date_0
${locator.questions[0].answer}                                 css=.q_answer_0
${locator.documents[0].title}                                  css=.lot_doc_title_0

${locator.questions[1].title}                                  css=.q_title_1
${locator.questions[1].description}                            css=.q_description_1
${locator.questions[1].date}                                   css=.q_date_1
${locator.questions[1].answer}                                 css=.q_answer_1
${locator.documents[1].title}                                  css=.lot_doc_title_1

*** Keywords ***

Підготувати дані для оголошення тендера
    [Arguments]  @{ARGUMENTS}
    ${period_interval}=  Get Broker Property By Username    ${ARGUMENTS[0]}   period_interval
    ${INITIAL_TENDER_DATA}=  prepare_test_tender_data   ${period_interval}   ${ARGUMENTS[1]}
    [return]   ${INITIAL_TENDER_DATA}

Оновити сторінку
  Reload Page

Відображення основних даних тендера
   return  ${locator}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  Set Global Variable   ${UBIZ_MODIFICATION_DATE}   ${EMPTY}
  Set Global Variable    ${GLOBAL_USER_NAME}    ${username}
  Open Browser  ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  '${username}' != 'ubiz_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Element Is Visible   id=btn_auth    10
  Click Element    id=btn_auth
  Sleep    1
  Input text   id=inputEmail1         ${USERS.users['${username}'].login}
  Input text   id=inputPassword1      ${USERS.users['${username}'].password}
  Click Element     css=.login-btn
  Wait Until Page Contains  Особистий кабінет   25
  Go To  ${USERS.users['${username}'].homepage}

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${tender_data}=  procuring_entity_name   ${ARGUMENTS[1]}
  ${items}=         Get From Dictionary    ${tender_data.data}               items
  ${dgfID}=         Get From Dictionary    ${tender_data.data}              dgfID
  ${title}=         Get From Dictionary    ${tender_data.data}               title
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ${budget}=        Get From Dictionary   ${tender_data.data.value}         amount
  ${step_rate}=     Get From Dictionary   ${tender_data.data.minimalStep}   amount
  ${guarantee}=   Get From Dictionary   ${tender_data.data.guarantee}   amount
  ${procuremnt_type}=   Get From Dictionary  ${tender_data.data}     procurementMethodType
  ${items_description}=   Get From Dictionary   ${items[0]}         description
  ${quantity}=         Get From Dictionary   ${items[0]}               quantity
  ${cav_id}=           Get From Dictionary   ${items[0].classification}         id
  ${unit_code}=        Get From Dictionary   ${items[0].unit}                 code
  #${latitude}       Get From Dictionary   ${items[0].deliveryLocation}    latitude
  #${longitude}      Get From Dictionary   ${items[0].deliveryLocation}    longitude
  #${postalCode}    Get From Dictionary   ${items[0].deliveryAddress}     postalCode
  ${streetAddress}    Get From Dictionary   ${items[0].deliveryAddress}     streetAddress
  ${deliveryDate}   Get From Dictionary   ${items[0].deliveryDate}        endDate
  ${auction_start_date}=    Get From Dictionary   ${tender_data.data.auctionPeriod}   startDate
   #${start_date}=   Get From Dictionary   ${tender_data.data.tenderPeriod}   startDate
  #${start_date}=    convert_datetime_for_delivery   ${start_date}
  #${end_date}=      Get From Dictionary   ${tender_data.data.tenderPeriod}   endDate
  #${end_date}=      convert_datetime_for_delivery   ${end_date}
  #${enquiry_start_date}=    Get From Dictionary   ${tender_data.data.enquiryPeriod}   startDate
  # ${enquiry_start_date}=    convert_datetime_for_delivery   ${enquiry_start_date}
  #${enquiry_end_date}=      Get From Dictionary   ${tender_data.data.enquiryPeriod}   endDate
  # ${enquiry_end_date}=    convert_datetime_for_delivery   ${enquiry_start_date}
  ${auction_start_date}=      convert_datetime_for_delivery   ${auction_start_date}
  ${budget} =    Convert To String   ${budget}
  ${step_rate}=  Convert To String   ${step_rate}
  ${guarantee}=  Convert To String   ${guarantee}

   Зайти в розділ створення лоту
   Sleep    2
   Input text     id=OpLotForm_op_dgfID     ${dgfID}
   Input text     id=title                  ${title}
   Input text     id=desc            ${description}
   Click Element  xpath=//a[contains(@id, 'to_params')]
   Sleep    5
   Select From List By Value   xpath=//select[contains(@id, 'procurement_method_type')]  ${procuremnt_type}
   Input text     id=initial_costs_id     ${budget}
   Click Element  id=value_added_tax_included
   Input text     id=step_id            ${step_rate}
   Input text     id=garvnesok_id        ${guarantee}
   Input text     id=datetimepicker5    ${auction_start_date}
   Sleep    1
   Click Element                     xpath=//a[contains(@id, 'submit_button')]


  Додати предмет   ${items[0]}   0
# Run Keyword if   '${mode}' == 'multi'   Додати багато предметів   items
#  Sleep  1
#  Wait Until Page Contains Element   css=.btn btn-success btn-lg pull-right  20
#  Sleep  10
  Wait Until Page Contains  Успішно додано  60
  Оновити сторінку
  Wait Until Element Is Enabled  id=btn_finished  10
  Click Element  id=btn_finished

  Wait Until Page Contains  Заявка на торги  25
  Клацнути перший елемент з випадаючого списку
  Sleep   1
  Click Element      css=.publish-lot
  Wait Until Page Contains  Запис знаходиться в стані очікування публікації в ЦБД  15
  Reload page

  Sleep  1
  ${tender_url}=    Get Element Attribute   css=.lot-url@href
  Go To  ${tender_url}
  Sleep  1
  Wait Until Page Contains  Лот №   10
  ${tender_UAid}=  Get Text  id=auid
  ${Ids}=   Convert To String   ${tender_UAid}
  ${lotID}=   Отримати інформацію про lotID
  Set Global Variable   ${LOT_ID}     ${lotID}
  Set Global Variable    ${GLOBAL_UAID}    ${tender_UAid}
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
  ${description_class}=   Get From Dictionary   ${ARGUMENTS[0].classification}        description
  ${description}=   Get From Dictionary   ${ARGUMENTS[0]}              description
  ${cav_id}=        Get From Dictionary   ${ARGUMENTS[0].classification}              id
  ${unit_code}=     Get From Dictionary   ${ARGUMENTS[0].unit}    code
  ${quantity}=      Get From Dictionary   ${ARGUMENTS[0]}         quantity

  Input text  id=OpItem_op_description  ${description}
  Input text  id=OpItem_op_quantity  ${quantity}
  Select From List By Value   xpath=//select[contains(@id, 'OpItem_op_unit_code')]  ${unit_code}
  Click Element  id=OpItem_op_classification_id_chosen
  Sleep    2
  Input Text  xpath=//div[@class='chosen-search']/input[@type='text']   ${cav_id}
  Sleep    3
  Wait Until Element Is Visible  css=.active-result  5
  Click Element  css=.active-result
  Sleep  2
  Click Element   xpath=//input[@type='submit']

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
    Клацнути і дочекатися  xpath=//a[contains(@class, 'btn btn-default btn-icon')]  xpath=(//*[@class='row itemlot'])  5

Пошук тендера по ідентифікатору
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
    Selenium2Library.Switch browser   ${ARGUMENTS[0]}
    Wait Until Page Contains Element    id=searchBar    10
    Input Text    id=inputsearch    ${ARGUMENTS[1]}
    ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
    ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout_on_wait} s  0 s  Шукати і знайти
    Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за ${timeout_on_wait} секунд
    Wait Until Page Contains Element    xpath=(//*[@class='row itemlot'])    10
    Click Element    xpath=(//div[@class='images-caption'])/a
    Wait Until Page Contains    ${ARGUMENTS[1]}   10

Пошук тендера у разі наявності змін
  [Arguments]  ${last_mod_date}  ${username}  ${tender_uaid}
  ${status}=   Run Keyword And Return Status   Should Not Be Equal   ${UBIZ_MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword If   ${status}   ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Set Global Variable   ${UBIZ_MODIFICATION_DATE}   ${last_mod_date}

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
Додати фінкомпанію
    Input text    id=PersonForm_op_ua_fin                123456
    Input text    id=PersonForm_op_ua_fin_legalname       test

Змінити документ в ставці
    [Arguments] ${username} ${tender_uaid} ${path} ${docid}
    Fail    Після відправки заявки оператору майданчика  - змінити доки неможливо
Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=             Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  ${bid}=             Convert To String   ${bid}
  ${flag}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${ARGUMENTS[2].data}  qualified
  Run Keyword And Return If   ${flag}   Fail    Учасник не кваліфікований
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${procedure}=   Отримати текст із поля і показати на сторінці   procedure
  Click Element                     id=take_part_but_wid
  Wait Until Page Contains          Стати учасником:    15
  Wait Until Page Contains Element          id=initial_costs   15
  Input text    id=initial_costs                  ${bid}
  Run keyword if   '${procedure}' == 'Право вимоги'   Додати фінкомпанію
  Wait Until Element Is Visible   id=but_to_step_2   5
  Click Element   id=but_to_step_2
  Wait Until Element Is Visible   id=but_to_step_3   5
  Click Element   id=but_to_step_3
  Wait Until Element Is Visible   id=but_to_step_4   5
  Click Element   id=but_to_step_4
  Wait Until Element Is Visible   id=but_save   5
  Click Element   id=but_save
  Wait Until Page Contains   Заявка на участь в аукціоні збережена   10
  Перевірити та сховати повідомлення

Відправлення заявки на участь
  Зайти в розділ купую
  Sleep    2    reason=None
  Click Element   css=.bid-send
  Перевірити та сховати повідомлення
  Sleep    2    reason=None
  Click Element     css=.bid-proved
Видалити документ
   Click Element   xpath=//a[contains(text(), 'Видалити')]
Завантажити документ в ставку
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[2]}
  ${procedure}=   Отримати текст із поля і показати на сторінці   procedure
  Зайти в розділ купую
  Click Element   css=.bid-edit
  Wait Until Element Is Visible   id=but_to_step_2   5
  Click Element   id=but_to_step_2
  Wait Until Element Is Visible   id=but_to_step_3   5
  Click Element   id=but_to_step_3
  Wait Until Element Is Visible   id=but_to_step_4   5
  Click Element   id=but_to_step_4
  Wait Until Element Is Visible   id=but_save   5
  ${resp}=   Run Keyword And Return Status   Element Should Be Visible   xpath=//a[contains(text(), 'Видалити')]
  Run Keyword If    "${resp}" == "True"   Видалити документ
  Run keyword if   '${procedure}' == 'Право вимоги'   Приєднати документ   id=fileInput21   ${ARGUMENTS[1]}
  Run keyword if   '${procedure}' == 'Майно банку'   Приєднати документ   id=fileInput1   ${ARGUMENTS[1]}
  Wait Until Page Contains   Видалити   15
  Click Element                    id=but_save
  Перевірити та сховати повідомлення
  Sleep    2
  Відправлення заявки на участь

Приєднати документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${element}
  ...      ${ARGUMENTS[1]} ==  ${flepath}
  Choose File      ${ARGUMENTS[0]}  ${ARGUMENTS[1]}

Перевірити та сховати повідомлення
  ${resp}=   Run Keyword And Return Status   Element Should Be Visible   id=close_inform_window
  Run Keyword If    "${resp}" == "True"   Сховати повідомлення

Переглянути повідомлення
  Сlick Element   css=.hide-alert
Сховати повідомлення
  Click Element   id=close_inform_window

скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Зайти в розділ купую
  Click Element               css=.bid-skas

Зайти в розділ купую
  Click Element               css=.my-cabinet
  Click Element               css=.my-buy-menu

Зайти в розділ офіс замовника
  Click Element  css=.my-cabinet
  Click Element   css=.customer-office

Зайти в розділ кваліфікація
  Зайти в розділ офіс замовника
  Click Element  css=.qualification

Зайти в розділ контракти
  Зайти в розділ офіс замовника
  Click Element   css=.contracts

Зайти в розділ заявок на торги
  Зайти в розділ офіс замовника
  Click Element   css=.application

Клацнути перший елемент з випадаючого списку
  Wait Until Element Is Visible   xpath=//button[contains(@class,'btn btn-primary dropdown-toggle')][1]
  Click Element   xpath=//button[contains(@class,'btn btn-primary dropdown-toggle')][1]

Зайти в розділ списку лотів
  Зайти в розділ заявок на торги
  Клацнути перший елемент з випадаючого списку
  Sleep    2
  Click Element   css=.list-lot-by-app

Зайти в розділ створення лоту
  Зайти в розділ списку лотів
  Click Element   css=.add-lot

Отримати інформацію із пропозиції
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${field}
  Sleep    1
  Зайти в розділ купую
  Sleep    2
  Click Element               css=.change_bid
  sleep   3
  ${return}=    Отримати інформацію про розмір ставки
  Перевірити та сховати повідомлення
  [return]   ${return}

Змінити цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${field}
  ...      ${ARGUMENTS[3]} ==  ${value}
  Зайти в розділ купую
  Click Element     css=.change_bid
  sleep   4
  ${bid value}=     Convert To String       ${ARGUMENTS[3]}
  Input text        id=input_value_amount   ${bid value}
  Click Element     id=sendform
  Sleep    5
  Перевірити та сховати повідомлення
  Sleep    10

Опублікувати ставку
  Зайти в розділ купую

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Go To  ${BROKERS['ubiz'].syncpage}
  Go To  ${BROKERS['ubiz'].homepage}
  ubiz.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}

Задати запитання на тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = question_data
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   id=create_question   10
  Click Element                      id=create_question
  Sleep    5
  Input text                         id=OpQuestion_op_title                 ${title}
  Input text                         id=OpQuestion_op_description           ${description}
  Sleep    1
  Click Element                      xpath=//input[@type='submit']
  Wait Until Page Contains    Питання успішно додане    8
  Перевірити та сховати повідомлення

Задати запитання на предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = ${item_id}
  ...      ${ARGUMENTS[3]} = question_data
  ${title}=        Get From Dictionary  ${ARGUMENTS[3].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[3].data}  description
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   id=create_question   10
  Click Element                      id=create_question
  Sleep    5
  Select From List By Value   xpath=//select[@id='OpQuestion_op_question_of']   item
  Sleep    2
  ${item_option}=   Get Text   //option[contains(text(), '${ARGUMENTS[2]}')]
  Select From List By Label   id=OpQuestion_op_related_item   ${item_option}
  Input text                         id=OpQuestion_op_title                 ${title}
  Input text                         id=OpQuestion_op_description           ${description}
  Sleep    1
  Click Element                      xpath=//input[@type='submit']
  Wait Until Page Contains    Питання успішно додане    8
  Перевірити та сховати повідомлення

Відповісти на запитання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = answer_data
  ...      ${ARGUMENTS[3]} = ${question_id}
  ${answer}=     Get From Dictionary  ${ARGUMENTS[2].data}  answer
  ${id}=   concat   q_add_answer_  ${ARGUMENTS[3]}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep    4
  Показати вкладку запитання
  Wait Until Page Contains Element    id=${id}    5
  Click Element                       id=${id}
  Sleep    3
  Wait Until Page Contains   Дати відповідь  5
  Input text                         id=OpQuestion_op_answer           ${answer}
  Click Element                      xpath=//input[@type='submit']
  Wait Until page Contains   Відповідь успішно опублікована    10
  Перевірити та сховати повідомлення

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  single
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}

додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  3
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval

  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  multi
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

Відправити документи до цбд
  ${location}=    Get Location
  Go To  ${BROKERS['ubiz'].syncdocs}
  Go to  ${location}

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tedner_uaid
  ...      ${ARGUMENTS[2]} ==  fieldname
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  3
  Wait Until Page Contains Element    ${locator.${fieldname}}    22
  Sleep  1
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про status
  ${return_value}=   Отримати текст із поля і показати на сторінці   status
  ${status}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]   ${status}
Отримати інформацію про eligibilityCriteria
  ${return_value}=   Отримати текст із поля і показати на сторінці   eligibilityCriteria
  [return]   ${return_value}
Отримати інформацію про procedure
  ${return_value}=   Отримати текст із поля і показати на сторінці   procedure
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]   ${return_value}

Отримати інформацію про lotID
  ${return_value}=   Отримати текст із поля і показати на сторінці   lotID
  [return]   ${return_value}
Отримати інформацію про dgfID
  ${return_value}=   Отримати текст із поля і показати на сторінці   dgfID
  [return]  ${return_value}
Отримати інформацію про title
  ${return_value}=   Отримати текст із поля і показати на сторінці   title
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про розмір ставки
  ${return_value}=   Отримати текст із поля і показати на сторінці   mybid
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}


Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Відмітити на сторінці поле з тендера
  [Arguments]   ${fieldname}  ${locator}
  ${last_note_id}=  Add pointy note   ${locator}   Found ${fieldname}   width=200  position=bottom
  Align elements horizontally    ${locator}   ${last_note_id}
  sleep  1
  Remove element   ${last_note_id}

Отримати інформацію про auctionID
  ${return_value}=   Отримати текст із поля і показати на сторінці   auctionID
  [return]  ${return_value}

Отримати інформацію про value.currency
  ${return_value}=   Отримати текст із поля і показати на сторінці   value.currency
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати текст із поля і показати на сторінці   value.valueAddedTaxIncluded
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  ${return_value}=   Convert To Boolean   ${return_value}
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]  ${return_value}

Отримати інформацію про auctionPeriod.startDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці    auctionPeriod.startDate
  ${return_value}=   convert_date_for_compare_full   ${return_value}
  [return]  ${return_value}

Доступний елемент   ${locator}
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   ${locator}
  [return]    ${present}

Отримати інформацію про auctionPeriod.endDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці   auctionPeriod.endDate
  ${return_value}=   convert_date_for_compare_full   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=   convert_date_for_compare_full   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   convert_date_for_compare_full   ${return_value}
  Показати вкладку параметри майна
  [return]  ${return_value}

Отримати інформацію про qualificationPeriod.startDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.startDate
  ${return_value}=   convert_date_for_compare_full   ${return_value}
  [return]  ${return_value}

Отримати інформацію про qualificationPeriod.endDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.endDate
  ${return_value}=   convert_date_for_compare_full   ${return_value}
  Показати вкладку параметри майна
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  Fail  enquiryPeriod відсутній

Отримати інформацію про enquiryPeriod.endDate
  Fail  enquiryPeriod відсутній

Отримати інформацію про предмет description
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].description
  [return]  ${return_value}

Отримати інформацію про предмет unit.code
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].unit.code
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про предмет unit.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].unit.code
  [return]  ${return_value}

Отримати інформацію про предмет quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про предмет classification.id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  [return]  ${return_value}

Отримати інформацію про предмет classification.description
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.description
  [return]  ${return_value}

Отримати інформацію про предмет classification.scheme
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.scheme
  [return]  ${return_value}

Показати вкладку параметри майна
  Click Link    xpath=//*[contains(@id, 'button_tab1')]

Показати вкладку параметри аукціону
  Click Link    xpath=//*[contains(@id, 'button_tab2')]

Показати вкладку запитання
  Click Link    xpath=//*[contains(@id, 'button_tab3')]


Отримати інформацію із предмету
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword And Return  Отримати інформацію про предмет ${ARGUMENTS[3]}

Отримати посилання на аукціон для глядача
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Run Keyword And Return  Отримати посилання на аукціон  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}

Отримати посилання на аукціон для учасника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Run Keyword And Return  Отримати посилання на аукціон   ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

Отримати посилання на аукціон
  [Arguments]   @{ARGUMENTS}
  ubiz.Оновити сторінку з тендером  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Run Keyword And Return    Get Element Attribute   css=.auction-url@href

Завантажити протокол аукціону
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ...   ${ARGUMENTS[2]} == filepath
  ...   ${ARGUMENTS[3]} == award_index
  ubiz.Оновити сторінку з тендером  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  ${lot_id}=    Отримати інформацію про lotID
  Зайти в розділ купую

Підтвердити підписання контракту
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ubiz.Оновити сторінку з тендером  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  ${lot_id}=    Отримати інформацію про lotID
  Зайти в розділ контракти
  ${drop_id}=  concat  ${lot_id}  _pending
  ${id}=     concat  ${lot_id}  _publish_contract
  Клацнути по випадаючому списку     ${drop_id}
  Wait Until Page Contains   Публікація контракту   5
  Виконати дію    ${id}
  Wait Until Page Contains   Реєстрація контракту   10
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${date}=   get_cur_date
  Input Text    id=OpContract_op_contract_number    123
  Input Text    id=datetimepicker5    ${date}
  Приєднати документ    id=fileInput2   ${file_path}
  Wait Until Page Contains   Видалити   15
  Click Element   xpath=//input[@class="btn btn-primary bnt-lg pull-right"]
  Wait Until Page Contains   Договір знаходиться в стані очікування публікації в ЦБД   15
  Перевірити та сховати повідомлення

Клацнути по випадаючому списку
   [Arguments]   ${id_val}
   Click Element    id=${id_val}

Виконати дію
  [Arguments]   ${id_val}
  Click Element   id=${id_val}

Підтвердження дії в модальном вікні
  Wait Until Element Is Visible   xpath=//button[contains(., "Підтвердити")]    10
  Click Element   xpath=//button[contains(., "Підтвердити")]

Підтвердити протокол
  [Arguments]   ${lot_id}
  ${drop_id}=  concat  ${lot_id}  _pending
  ${id}=     concat  ${lot_id}  _confirm_protocol
  Клацнути по випадаючому списку     ${drop_id}
  Wait Until Page Contains   Переглянути та підтвердити протокол  5
  Виконати дію    ${id}
  Wait Until Page Contains    Учасник по лоту   10
  Click Element   css=.accepted
  Підтвердження дії в модальном вікні
  Wait Until Page Contains   Кваліфікація учасників   20

Підтвердити оплату
  [Arguments]   ${lot_id}
  ${drop_id}=  concat  ${lot_id}  _pending
  ${id}=     concat  ${lot_id}  _confirm_payment
  Клацнути по випадаючому списку     ${drop_id}
  Wait Until Page Contains    Підтвердити оплату   5
  Виконати дію    ${id}
  Wait Until Page Contains    Ви дійсно підтверджуєте оплату та кваліфікуете учасника?    10
  Підтвердження дії в модальном вікні
  Wait Until Page Contains   Учасник кваліфікований   10
  Перевірити та сховати повідомлення

Підтвердити постачальника
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${lot_id}=    Отримати інформацію про lotID
  Зайти в розділ кваліфікація
  Wait Until Page Contains   Кваліфікація учасників   10
  Підтвердити протокол  ${lot_id}
  Wait Until Page Contains   Кваліфікація учасників    10
  Підтвердити оплату     ${lot_id}

Завантажити ілюстрацію
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ...   ${ARGUMENTS[2]} == filepath
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${lot_id}=   Отримати інформацію про lotID
  ${id}=   concat  ${lot_id}  _add_imgs
  ${drop_id}=  concat  lot_  ${lot_id}
  Sleep    2
  Зайти в розділ списку лотів
  Sleep    1
  Клацнути по випадаючому списку   ${drop_id}
  Виконати дію    ${id}
  Sleep   5
  Приєднати документ    id=fileUploadInput    ${ARGUMENTS[2]}
  Sleep    10
  Відправити документи до цбд

Додати Virtual Data Room
    [Arguments]   @{ARGUMENTS}
    [Documentation]
    ...   ${ARGUMENTS[0]} == username
    ...   ${ARGUMENTS[1]} == tender_uaid
    ...   ${ARGUMENTS[2]} == link
    ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
    ${lot_id}=   Отримати інформацію про lotID
    ${id}=   concat  ${lot_id}  _add_vdr
    ${drop_id}=  concat  lot_  ${lot_id}
    Sleep    2
    Зайти в розділ списку лотів
    Sleep    2
    Клацнути по випадаючому списку  ${drop_id}
    Sleep    2
    Виконати дію     ${id}
    Sleep   2
    Input Text   id=OpLotForm_op_vdr_link  ${ARGUMENTS[2]}
    Sleep    2
    Click Element  xpath=//input[@type="submit"]
    Sleep    3
    Перевірити та сховати повідомлення

Дочекатися відображення запитання на сторінці
  [Arguments]  ${text}
  Reload Page
  Показати вкладку запитання
  Wait Until Page Contains   ${text}

Отримати інформацію із запитання
    [Arguments]   @{ARGUMENTS}
    [Documentation]
    ...   ${ARGUMENTS[0]} == username
    ...   ${ARGUMENTS[1]} == tender_uaid
    ...   ${ARGUMENTS[2]} == question_id
    ...   ${ARGUMENTS[3]} == field_name
    ubiz.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}  ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
    Wait Until Element Is Visible   id=button_tab3
    Wait Until Keyword Succeeds   15 x   20 s    Дочекатися відображення запитання на сторінці   ${ARGUMENTS[2]}
    ${q_id}=   create_question_id  ${ARGUMENTS[3]}  ${ARGUMENTS[2]}
    ${question_value}=   Get Text   id=${q_id}
    [return]  ${question_value}

Отримати інформацію про questions[0].title
  Показати вкладку запитання
  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[0].title

Отримати інформацію про questions[0].description
  Показати вкладку запитання
  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[0].description

Отримати інформацію про questions[0].date
  Показати вкладку запитання
  ${return_value}=  Отримати текст із поля і показати на сторінці  questions[0].date
  Run Keyword And Return  convert_date_for_compare_full  ${return_value}

Отримати інформацію про questions[0].answer
  Показати вкладку запитання
  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[1].answer

Отримати інформацію про questions[1].title
    Показати вкладку запитання
    Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[1].title

Отримати інформацію про questions[1].description
    Показати вкладку запитання
    Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[1].description

Отримати інформацію про questions[1].date
    Показати вкладку запитання
    ${return_value}=  Отримати текст із поля і показати на сторінці  questions[1].date
    Run Keyword And Return  convert_date_for_compare_full  ${return_value}

Отримати інформацію про questions[1].answer
    Показати вкладку запитання
    Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[1].answer

Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${username}   ${tender_uaid}
  Показати вкладку параметри майна
  ${file_title}=   Get Text   xpath=//a[contains(text(),'${doc_id}')]
  [return]   ${file_title}

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${username}   ${tender_uaid}
  Показати вкладку параметри майна
  ${file_name}=   Get Text   xpath=//a[contains(text(),'${doc_id}')]
  ${url}=    Get Element Attribute   xpath=//a[contains(text(),'${doc_id}')]@href
  ${filename}=   download_file_from_url  ${url}  ${OUTPUT_DIR}${/}${file_name}
  [return]   ${filename}
