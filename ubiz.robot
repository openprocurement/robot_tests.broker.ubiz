*** Settings ***
#Library  Selenium2Screenshots
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
${locator.dgfDecisionID}                                       id=op_dgfDecisionID
${locator.dgfDecisionDate}                                     id=op_dgfDecisionDate
${locator.tenderAttempts}                                      id=op_tenderAttempts

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
${locator.documents[1].title}                                  css=.lot_doc_title
${locator.cancellations[0].status}                             css=.cancellation_status_0
${locator.cancellations[0].reason}                             css=.cancellation_reason_0
${locator.cancellations[0].documents[0].title}                 css=.cancelletion_doc_title_0
${locator.cancellations[0].documents[0].description}           css=.cancelletion_doc_description_0

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
  Set Global Variable   ${UBIZ_LOT_ID}   ${EMPTY}
  Set Global Variable    ${UBIZ_MODIFICATION_DATE}   ${EMPTY}
  Set Global Variable    ${GLOBAL_USER_NAME}    ${username}
  Open Browser  ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  '${username}' != 'ubiz_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Element Is Visible   id=btn_auth    10
  Click Element    id=btn_auth
  Wait Until Element Is Visible   id=inputEmail1   5
  Input text   id=inputEmail1         ${USERS.users['${username}'].login}
  Input text   id=inputPassword1      ${USERS.users['${username}'].password}
  Click Element   css=.login-btn
  Wait Until Page Contains  Особистий кабінет   60

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${tender_data}=         procuring_entity_name   ${ARGUMENTS[1]}
  ${dgfDecisionDate}=     Get From Dictionary   ${tender_data.data}   dgfDecisionDate
  ${dgfDecisionID}=       Get From Dictionary   ${tender_data.data}   dgfDecisionID
  ${items}=               Get From Dictionary   ${tender_data.data}   items
  ${dgfID}=               Get From Dictionary   ${tender_data.data}   dgfID
  ${title}=               Get From Dictionary   ${tender_data.data}   title
  ${description}=         Get From Dictionary   ${tender_data.data}   description
  ${budget}=              Get From Dictionary   ${tender_data.data.value}   amount
  ${step_rate}=           Get From Dictionary   ${tender_data.data.minimalStep}   amount
  ${guarantee}=           Get From Dictionary   ${tender_data.data.guarantee}   amount
  ${procuremnt_type}=     Get From Dictionary   ${tender_data.data}   procurementMethodType
  ${items_description}=   Get From Dictionary   ${items[0]}   description
  ${quantity}=            Get From Dictionary   ${items[0]}   quantity
  ${cav_id}=              Get From Dictionary   ${items[0].classification}   id
  ${unit_code}=           Get From Dictionary   ${items[0].unit}   code
  ${streetAddress}        Get From Dictionary   ${items[0].deliveryAddress}  streetAddress
  ${deliveryDate}         Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${auction_start_date}=  Get From Dictionary   ${tender_data.data.auctionPeriod}   startDate
  ${auction_start_date}=  convert_datetime_for_delivery   ${auction_start_date}
  ${budget} =             Convert To String   ${budget}
  ${step_rate}=           Convert To String   ${step_rate}
  ${guarantee}=           Convert To String   ${guarantee}

   Зайти в розділ створення лоту
   Wait Until Element Is Visible   id=OpLotForm_op_dgfID   5
   Input text   id=OpLotForm_op_dgfID   ${dgfID}
   Input Text   id=OpLotForm_op_dgfDecisionID   ${dgfDecisionID}
   Input Text   id=OpLotForm_op_dgfDecisionDate   ${dgfDecisionDate}
   Input text   id=title   ${title}
   Input text   id=desc   ${description}
   Click Element   id=to_params
   Wait Until Element Is Visible   id=submit_button   10
   Select From List By Value   xpath=//select[contains(@id, 'procurement_method_type')]   ${procuremnt_type}
   ${tenderAttempts}=   Get From Dictionary    ${tender_data.data}   tenderAttempts
   ${tenderAttempts}=   Convert To String    ${tenderAttempts}
   Select From List By Value   xpath=//select[@id='OpLotForm_number_auction']  ${tenderAttempts}
   Input text     id=initial_costs_id   ${budget}
   Click Element  id=value_added_tax_included
   Input text   id=step_id   ${step_rate}
   Input text   id=garvnesok_id   ${guarantee}
   Input text   id=datetimepicker5   ${auction_start_date}
   Click Element   id=submit_button
   Wait Until Element Is Visible   xpath=//a[contains(text(),'< До списку активів')]   15
   Click Element   xpath=//a[contains(text(),'< До списку активів')]
   Wait Until Element Is Visible   xpath=//*[contains(text(),'Додати')]   10
   Додати багато предметів   ${items}

   ${lotID}=   Get Text    id=lotID
   Set Global Variable   ${UBIZ_LOT_ID}   ${lotID}
   Click Element  id=btn_finished
   Wait Until Page Contains  Заявка на торги  30
   ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
   ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _publish_lot
   Клацнути по випадаючому списку   ${drop_id}
   Виконати дію   ${action_id}
   Wait Until Page Contains   Запис знаходиться в стані очікування публікації в ЦБД   60
   Перевірити та сховати повідомлення
   Wait Until Element Is Visible   xpath=//a[contains(@href,'${UBIZ_LOT_ID}')]   15
   Click Link   xpath=//a[contains(@href,'${UBIZ_LOT_ID}')]
   Wait Until Page Contains   Ідентифікатор аукціону   30
   ${ua_id}=   Get Text  id=auid
   [return]   ${ua_id}

Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${current_location}=      Get Location
  ${id}=    Get Substring   ${current_location}   10
  ${Ids}=   Create List     ${tender_UAid}   ${id}

Додати предмет
  [Arguments]   ${item}   ${index}
  ${description_class}=   Get From Dictionary   ${item.classification}   description
  ${description}=   Get From Dictionary   ${item}   description
  ${cav_id}=        Get From Dictionary   ${item.classification}   id
  ${unit_code}=     Get From Dictionary   ${item.unit}   code
  ${quantity}=      Get From Dictionary   ${item}   quantity

  ${locality}=   Get From Dictionary   ${item.deliveryAddress}   locality
  ${region}=   Get From Dictionary   ${item.deliveryAddress}   region
  ${streetAddress}=   Get From Dictionary   ${item.deliveryAddress}   streetAddress
  ${postCode}=   Get From Dictionary   ${item.deliveryAddress}   postalCode
  Input text  id=OpItem_op_description   ${description}
  Input text  id=OpItem_op_quantity   ${quantity}
  Select From List By Value   xpath=//select[contains(@id, 'OpItem_op_unit_code')]  ${unit_code}
  Click Element  id=OpItem_op_classification_id_chosen
  Input Text   xpath=//div[@class='chosen-search']/input[@type='text']   ${cav_id}
  Wait Until Element Is Visible  css=.active-result  5
  Click Element  css=.active-result
  Run Keyword And Ignore Error    Select From List By Label   xpath=//select[@id='op_address_region_id']   ${region}
  Input Text   id=OpItem_op_address_locality   ${locality}
  Input Text   id=OpItem_op_address_street_address   ${streetAddress}
  Input Text   id=OpItem_op_address_postal_code   ${postCode}
  Click Element   xpath=//input[@type='submit']

Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  ${status}=    Run Keyword And Return Status   Перейти в розділ додавання активів
  Return From Keyword If    ${status} == False    ${status}
  Wait Until Element Is Visible   xpath=//*[contains(text(), 'Додати')]   20
  Click Element   xpath=//*[contains(text(), 'Додати')]
  Wait Until Element Is Visible   id=OpItem_op_description   10
  Додати предмет   ${item}   0
  Wait Until Page Contains   Успішно додано   15
  Перевірити та сховати повідомлення

Перейти в розділ додавання активів
  Зайти в розділ списку лотів
  ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _edit_lot
  Клацнути по випадаючому списку   ${drop_id}
  Виконати дію   ${action_id}
  Wait Until Element Is Visible   id=to_params   15
  Click Element  id=to_params
  Wait Until Element Is Visible   id=submit_button
  Click Element   id=submit_button

Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}
  ${status}=    Run Keyword And Return Status   Перейти в розділ додавання активів
  Return From Keyword If    ${status} == False    ${status}
  Wait Until Element Is Visible   xpath=//*[contains(@class, 'pull-right') and contains(@class,'accepted')]   20
  Click Element    xpath=//*[contains(@class, 'pull-right') and contains(@class,'accepted')]
  Підтвердження дії в модальном вікні

Додати багато предметів
  [Arguments]  ${items}
  ${itemslength}=   Get Length   ${items}
  : FOR    ${index}    IN RANGE   ${itemslength}
  \   Click Element   xpath=//*[contains(text(), 'Додати')]
  \   Wait Until Element Is Visible   id=OpItem_op_description   10
  \   Додати предмет   ${items[${index}]}   ${index}
  \   Wait Until Page Contains   Успішно додано   20
  \   Перевірити та сховати повідомлення

Клацнути і дочекатися
    [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
    [Documentation]
    ...      click_locator: Where to click
    ...      wanted_locator: What are we waiting for
    ...      timeout: Timeout
    Click Element  ${click_locator}
    Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
    [Arguments]   ${tender_uaid}
    Input Text    id=inputsearch    ${tender_uaid}
    Клацнути і дочекатися  xpath=//a[contains(@class, 'btn btn-default btn-icon')]  xpath=(//*[@class='row itemlot'])  5

Зберегти ід лоту майданчка
    ${lotID}=  Отримати інформацію про lotID
    Set Global Variable   ${UBIZ_LOT_ID}  ${lotID}


Пошук тендера по ідентифікатору
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
    Selenium2Library.Switch browser   ${ARGUMENTS[0]}
    Wait Until Page Contains Element    id=searchBar    30
    ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
    ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds   6 x  ${timeout_on_wait} s  Шукати і знайти   ${ARGUMENTS[1]}
    Run Keyword Unless  ${passed}  Fail  Тендер не знайдено за ${timeout_on_wait} секунд
    Click Element    xpath=(//div[@class='images-caption'])/a
    Wait Until Page Contains    ${ARGUMENTS[1]}   30
    ${flag}=  Run Keyword And Return Status  Should Be Empty  ${UBIZ_LOT_ID}
    Run Keyword If  ${flag}   Зберегти ід лоту майданчка

Пошук тендера у разі наявності змін
  [Arguments]  ${last_mod_date}  ${username}  ${tender_uaid}
  ${status}=   Run Keyword And Return Status   Should Not Be Equal   ${UBIZ_MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword If   ${status}   ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Set Global Variable   ${UBIZ_MODIFICATION_DATE}   ${last_mod_date}

Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${documentType}
  Зайти в розділ списку лотів
  ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _add_files
  Клацнути по випадаючому списку   ${drop_id}
  Виконати дію   ${action_id}
  Wait Until Element Is Visible   xpath=//input[@type='submit']   10
  ${inputID}=   convert_ubiz_string_to_common_string   ${documentType}
  Приєднати документ    id=${inputID}   ${filepath}
  Click Element  xpath=//input[@type="submit"]
  Wait Until Page Contains   Збережено   20
  Перевірити та сховати повідомлення

Отримати кількість предметів в тендері
    [Arguments]  ${username}  ${tender_uaid}
    ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
    ${number_of_items}=  Get Matching Xpath Count  //div[contains(@class,'item_description')]
    [return]  ${number_of_items}

Завантажити документ
    [Arguments]   @{ARGUMENTS}
    [Documentation]
    ...   ${ARGUMENTS[0]} == username
    ...   ${ARGUMENTS[1]} == filepath
    ...   ${ARGUMENTS[2]} == tender_uaid
    Зайти в розділ списку лотів
    ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
    ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _add_files
    Клацнути по випадаючому списку   ${drop_id}
    Виконати дію   ${action_id}
    Wait Until Element Is Visible   id=fileInput13   15
    Приєднати документ    id=fileInput13    ${ARGUMENTS[1]}
    Click Element  xpath=//input[@type="submit"]
    Wait Until Page Contains   Збережено   20
    Перевірити та сховати повідомлення

Додати фінкомпанію
    Input text    id=PersonForm_op_ua_fin                123456
    Input text    id=PersonForm_op_ua_fin_legalname       test

Змінити документ в ставці
   [Arguments]   ${username}   ${tender_uaid}    ${path}   ${docid}
    Fail    Після відправки заявки оператору майданчика  - змінити доки неможливо

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=             Get From Dictionary   ${ARGUMENTS[2].data.value}   amount
  ${bid}=             Convert To String   ${bid}
  ${qualified}=   Get From Dictionary   ${ARGUMENTS[2].data}   qualified
  Run Keyword And Return If   ${qualified} == False   Fail    Учасник не кваліфікований
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${procedure}=   Отримати текст із поля і показати на сторінці   procurementMethodType
  Click Element   id=take_part_but_wid
  Wait Until Page Contains   Стати учасником:    15
  Wait Until Page Contains Element   id=initial_costs   15
  Input text    id=initial_costs   ${bid}
  Run keyword if   '${procedure}' == 'Право вимоги'   Додати фінкомпанію
  Wait Until Element Is Visible   id=but_to_step_2   5
  Click Element   id=but_to_step_2
  Wait Until Element Is Visible   id=but_to_step_3   5
  Click Element   id=but_to_step_3
  Wait Until Element Is Visible   id=but_to_step_4   5
  Click Element   id=but_to_step_4
  Wait Until Element Is Visible   id=but_save   5
  Click Element   id=but_save
  Wait Until Page Contains   Заявки на участь у торгах   10
  Перевірити та сховати повідомлення
  Run keyword if   '${procedure}' != 'Право вимоги'   Відправлення заявки на участь

Відправлення заявки на участь
  Зайти в розділ купую
  Wait Until Element Is Visible   css=.bid-send   10
  Click Element   css=.bid-send
  Перевірити та сховати повідомлення
  Wait Until Element Is Visible   css=.bid-proved   10
  Click Element     css=.bid-proved
Видалити документ
   Click Element   xpath=//a[contains(text(), 'Видалити')]

Завантажити фінансову ліцензію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
    ...      ${ARGUMENTS[2]} ==  ${filepath}
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
    Приєднати документ   id=fileInput21   ${ARGUMENTS[2]}
    Wait Until Page Contains   Видалити   15
    Click Element   id=but_save
    Перевірити та сховати повідомлення
    Відправлення заявки на участь

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
  Sleep    5   Ждем зарузки документа

Перевірити та сховати повідомлення
  Sleep    1
  ${resp}=   Run Keyword And Return Status   Element Should Be Visible   id=close_inform_window
  Run Keyword If   ${resp} == ${True}   Сховати повідомлення

Переглянути повідомлення
  Сlick Element   css=.hide-alert

Сховати повідомлення
  Click Element   id=close_inform_window
  Sleep    2    Ждем закрытия модального окна

Скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Зайти в розділ купую
  ${visible}=   Run Keyword And Return Status   Element Should Be Visible  css=.bid-send
  Run Keyword If    "${visible}" == "True"   Відправлення заявки на участь
  Wait Until Element Is Visible   css=.bid-skas   10
  Click Element   css=.bid-skas
  Wait Until Page Contains   Пропозиція скасована   15
  Перевірити та сховати повідомлення

Зайти в розділ купую
  Wait Until Element Is Visible   css=.my-cabinet   10
  Click Element               css=.my-cabinet
  Wait Until Element Is Visible   css=.my-buy-menu   10
  Click Element               css=.my-buy-menu

Зайти в розділ офіс замовника
  Wait Until Element Is Visible   css=.my-cabinet   10
  Click Element               css=.my-cabinet
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
  Click Element   css=.change_bid
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
  Wait Until Element Is Visible   id=OpQuestion_op_title   15
  Input text                         id=OpQuestion_op_title                 ${title}
  Input text                         id=OpQuestion_op_description           ${description}
  Click Element                      xpath=//input[@type='submit']
  Wait Until Page Contains    Питання успішно додане    50
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
  Wait Until Page Contains Element   id=create_question   15
  Click Element                      id=create_question
  Wait Until Element Is Visible   id=OpQuestion_op_title   15
  Select From List By Value   xpath=//select[@id='OpQuestion_op_question_of']   item
  ${item_option}=   Get Text   //option[contains(text(), '${ARGUMENTS[2]}')]
  Select From List By Label   id=OpQuestion_op_related_item   ${item_option}
  Input text                         id=OpQuestion_op_title                 ${title}
  Input text                         id=OpQuestion_op_description           ${description}
  Click Element                      xpath=//input[@type='submit']
  Wait Until Page Contains    Питання успішно додане    40
  Перевірити та сховати повідомлення

Відповісти на запитання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = answer_data
  ...      ${ARGUMENTS[3]} = ${question_id}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${answer}=     Get From Dictionary  ${ARGUMENTS[2].data}  answer
  ${answer_btn_id}=   Catenate   SEPARATOR=   q_add_answer_  ${ARGUMENTS[3]}
  Wait Until Element Is Visible  id=button_tab3    15
  Показати вкладку запитання
  Wait Until Element Is Visible   id=${answer_btn_id}   5
  Click Element   id=${answer_btn_id}
  Wait Until Element Is Visible   id=OpQuestion_op_answer   10
  Input text   id=OpQuestion_op_answer   ${answer}
  Click Element   xpath=//input[@type='submit']
  Wait Until page Contains   Відповідь успішно опублікована    40
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
  Run keyword if   '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'   Додати позицію
  Run keyword if   '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'   Видалити позиції

Додати позицію
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

Видалити позиції
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
  ${resp}=   Run Keyword And Return Status   Element Should Be Visible   id=button_tab1
  Run Keyword If    "${resp}" == "False"   ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
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

Отримати інформацію про dgfDecisionID
  ${return_value}=   Отримати текст із поля і показати на сторінці   dgfDecisionID
  [return]   ${return_value}

Отримати інформацію про dgfDecisionDate
  ${return_value}=   Отримати текст із поля і показати на сторінці   dgfDecisionDate
  ${return_value}=   convert_date_to_dash_format   ${return_value}
  [return]   ${return_value}

Отримати інформацію про eligibilityCriteria
  ${return_value}=   Отримати текст із поля і показати на сторінці   eligibilityCriteria
  [return]   ${return_value}

Отримати інформацію про procurementMethodType
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

Отримати інформацію про tenderAttempts
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderAttempts
  [return]   ${return_value}

Отримати інформацію про auctionPeriod.startDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці    auctionPeriod.startDate
  ${return_value}=   subtract_from_time   ${return_value}  0   0
  [return]  ${return_value}

Отримати інформацію про auctionPeriod.endDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці   auctionPeriod.endDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  Показати вкладку параметри майна
  [return]  ${return_value}

Отримати інформацію про qualificationPeriod.startDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.startDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]  ${return_value}

Отримати інформацію про qualificationPeriod.endDate
  Показати вкладку параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.endDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
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
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  ${field_name_class}=  Catenate    SEPARATOR=   item_   ${field_name}
  ${item_value}=  Get Text   xpath=//*[contains(@class,'${item_id}') and contains(@class,'${field_name_class}')]
  ${item_value}=   adapt_items_data   ${field_name}   ${item_value}
  [return]  ${item_value}

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
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   css=.auction-url
  Run Keyword And Return    Get Element Attribute   css=.auction-url@href

Завантажити протокол аукціону
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ...   ${ARGUMENTS[2]} == filepath
  ...   ${ARGUMENTS[3]} == award_index
  ubiz.Оновити сторінку з тендером  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Зайти в розділ купую
  Wait Until Element Is Visible   css=.signed-protocol   10
  Click Element   css=.signed-protocol
  Wait Until Element Is Visible   id=fileInput20   10
  Приєднати документ   id=fileInput20   ${ARGUMENTS[2]}
  Click Element   xpath=//input[@type="submit"]
  Wait Until Page Contains   Протокол успішно завантажений в с-му   10
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
  ${drop_id}=   Catenate   SEPARATOR=   ${lot_id}  _pending
  ${id}=     Catenate   SEPARATOR=    ${lot_id}  _confirm_protocol
  Клацнути по випадаючому списку     ${drop_id}
  Wait Until Page Contains   Переглянути та підтвердити протокол  5
  Виконати дію    ${id}
  Wait Until Page Contains    Учасник по лоту   10
  Click Element   css=.accepted
  Підтвердження дії в модальном вікні

Підтвердити оплату
  [Arguments]   ${lot_id}
  ${drop_id}=   Catenate   SEPARATOR=   ${lot_id}  _pending
  ${id}=     Catenate   SEPARATOR=    ${lot_id}  _confirm_payment
  Клацнути по випадаючому списку     ${drop_id}
  Wait Until Page Contains    Підтвердити оплату   5
  Виконати дію    ${id}
  Wait Until Page Contains    Ви дійсно підтверджуєте оплату та кваліфікуете учасника?    10
  Підтвердження дії в модальном вікні
  Sleep   10  Ждем ответа от сервера
  Перевірити та сховати повідомлення

Підтвердити постачальника
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${lot_id}=    Отримати інформацію про lotID
  Зайти в розділ кваліфікація
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND    Підтвердити протокол  ${lot_id}
  Wait Until Page Contains   Кваліфікація учасників    10
  Підтвердити оплату     ${lot_id}

Завантажити ілюстрацію
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ...   ${ARGUMENTS[2]} == filepath
  Зайти в розділ списку лотів
  ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _add_imgs
  Клацнути по випадаючому списку   ${drop_id}
  Wait Until Page Contains    Завантажити фото   3
  Виконати дію   ${action_id}
  Wait Until Element Is Visible   id=fileUploadInput   10
  Приєднати документ    id=fileUploadInput    ${ARGUMENTS[2]}
  Відправити документи до цбд

Додати публічний паспорт активу
  [Arguments]  ${username}  ${tender_uaid}  ${certificate_url}
  Зайти в розділ списку лотів
  ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _add_assets_link
  Клацнути по випадаючому списку  ${drop_id}
  Виконати дію   ${action_id}
  Wait Until Element Is Visible   id=OpLotForm_op_assets_link   10
  Input Text   id=OpLotForm_op_assets_link  ${certificate_url}
  Click Element  xpath=//input[@type="submit"]
  Wait Until Page Contains   Посилання успішно прикріплене   30
  Перевірити та сховати повідомлення

Додати офлайн документ
  [Arguments]  ${username}  ${tender_uaid}  ${accessDetails}
  Зайти в розділ списку лотів
  ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _add_access_details
  Клацнути по випадаючому списку  ${drop_id}
  Виконати дію   ${action_id}
  Wait Until Element Is Visible   id=OpLotForm_op_accessDetails   10
  Input Text   id=OpLotForm_op_accessDetails  ${accessDetails}
  Click Element  xpath=//input[@type="submit"]
  Wait Until Page Contains   Документ успішно відправлений   30
  Перевірити та сховати повідомлення

Додати Virtual Data Room
    [Arguments]   @{ARGUMENTS}
    [Documentation]
    ...   ${ARGUMENTS[0]} == username
    ...   ${ARGUMENTS[1]} == tender_uaid
    ...   ${ARGUMENTS[2]} == link
    Зайти в розділ списку лотів
    ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
    ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _add_vdr
    Клацнути по випадаючому списку  ${drop_id}
    Wait Until Page Contains    Прикріпити посилання на вдр   3
    Виконати дію   ${action_id}
    Wait Until Element Is Visible   id=OpLotForm_op_vdr_link   10
    Input Text   id=OpLotForm_op_vdr_link  ${ARGUMENTS[2]}
    Sleep    2
    Click Element  xpath=//input[@type="submit"]
    Wait Until Page Contains   Посилання успішно прикріплене   30
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
  Run Keyword And Return  subtract_from_time  ${return_value}  0  0

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
  Run Keyword And Return  subtract_from_time  ${return_value}  0  0

Отримати інформацію про questions[1].answer
  Показати вкладку запитання
  Run Keyword And Return  Отримати текст із поля і показати на сторінці  questions[1].answer

Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
  ubiz.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${text}=  Get Text   xpath=//div[contains(@class,'lot_document') and contains(@class, '${field}') and contains(@class,'${document_index}')]
  ${text}=  convert_ubiz_string_to_common_string   ${text}
  [return]  ${text}

Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${username}   ${tender_uaid}
  Показати вкладку параметри майна
  ${class}=  Catenate   SEPARATOR=   ${field}  ${doc_id}
  Run Keyword And Return If  '${username}' == 'ubiz_Owner' and '${username}' == 'description'   Fail   Опис документа відсутній на юбіз
  ${doc_info}=   Get Text   xpath=//*[contains(@class,'${class}')]
  [return]   ${doc_info}

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${username}   ${tender_uaid}
  Показати вкладку параметри майна
  ${file_name}=   Get Text   xpath=//a[contains(text(),'${doc_id}')]
  ${url}=    Get Element Attribute   xpath=//a[contains(text(),'${doc_id}')]@href
  ${filename}=   download_file_from_url  ${url}  ${OUTPUT_DIR}${/}${file_name}
  [return]   ${filename}

Скасувати закупівлю
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  ...   ${ARGUMENTS[2]} == cancellation_reason
  ...   ${ARGUMENTS[3]} == filepath
  ...   ${ARGUMENTS[4]} == description
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Зайти в розділ списку лотів
  ${drop_id}=  Catenate   SEPARATOR=   lot_  ${UBIZ_LOT_ID}
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}  _cancel_lot
  Клацнути по випадаючому списку  ${drop_id}
  Wait Until Page Contains    Скасувати аукціон   3
  Виконати дію    ${action_id}
  Wait Until Element Is Visible   id=OpCancellation_reason_id   10
  Select From List By Label   id=OpCancellation_reason_id   ${ARGUMENTS[2]}
  Приєднати документ   id=fileInput0   ${ARGUMENTS[3]}
  Click Element  xpath=//input[@type="submit"]
  Sleep   5   Ждем ответ от сервера
  Перевірити та сховати повідомлення

Отримати інформацію про cancellations[0].status
  ${return_value}=   Отримати текст із поля і показати на сторінці   cancellations[0].status
  ${return_value}=   convert_ubiz_string_to_common_string  ${return_value}
  [return]  ${return_value}

Отримати інформацію про cancellations[0].reason
  ${return_value}=   Отримати текст із поля і показати на сторінці   cancellations[0].reason
  [return]  ${return_value}

Отримати інформацію про cancellations[0].documents[0].description
  ${description}=   Отримати текст із поля і показати на сторінці   cancellations[0].documents[0].description
  [return]  ${description}

Отримати інформацію про cancellations[0].documents[0].title
  ${title}=   Отримати текст із поля і показати на сторінці   cancellations[0].documents[0].title
  [return]  ${title}

Отримати інформацію про documents[0].title
  Показати вкладку параметри майна
  ${title}=   Отримати текст із поля і показати на сторінці   documents[0].title
  [return]  ${title}

Скасування рішення кваліфікаційної комісії
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...   ${ARGUMENTS[0]} == username
  ...   ${ARGUMENTS[1]} == tender_uaid
  Зайти в розділ кваліфікація
  ${drop_id}=  Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _active
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _cancel_award
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Клацнути по випадаючому списку  ${drop_id}
  ...   AND   Element Should Be Visible   id=${action_id}
  Виконати дію   ${action_id}
  Sleep    5   Ждем отображение модального окна
  Click Element   xpath=//input[@type="submit"]
  Wait Until Page Contains    Рішення успішно скасоване   20
  Перевірити та сховати повідомлення

Отримати кількість документів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${number_of_documents}=  Get Matching Xpath Count  //a[contains(@class,'lot_document_title')]
  [return]  ${number_of_documents}

Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Зайти в розділ кваліфікація
  ${drop_id}=  Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _pending
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _confirm_protocol
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Клацнути по випадаючому списку  ${drop_id}
  ...   AND   Element Should Be Visible   id=${action_id}
  Виконати дію   ${action_id}
  Wait Until Page Contains   Учасник по лоту   10
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Wait Until Page Contains   Підписаний протокол
  ${bid_doc_number}=   Get Matching Xpath Count   xpath=//a[contains(@class, 'document_title')]
  Log To Console    ${bid_doc_number}
  [return]  ${bid_doc_number}

Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  ${fileid_index}=   Catenate   SEPARATOR=   ${field}   ${document_index}
  ${doc_value}=   Get Text   xpath=//span[contains(@class, '${fileid_index}')]
  ${doc_value}=   convert_ubiz_string_to_common_string   ${doc_value}
  [return]  ${doc_value}

Завантажити документ рішення кваліфікаційної комісії
  [ARGUMENTS]   ${username}   ${file_path}  ${tender_uaid}  ${award_index}
  Зайти в розділ кваліфікація
  ${drop_id}=  Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _pending
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _disqualification
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Клацнути по випадаючому списку  ${drop_id}
  ...   AND   Element Should Be Visible   id=${action_id}
  Виконати дію   ${action_id}
  Sleep    5   Ждем отображение модального окна
  Приєднати документ    id=fileInput0    ${file_path}

Дискваліфікувати постачальника
  [ARGUMENTS]   ${user_name}   ${tender_uaid}  ${award_index}  ${description}
  Wait Until Page Contains    Дискваліфікація учасника    10
  Input Text  id=OpAward_op_title   Дискваліфікація
  Input Text  id=OpAward_op_description   ${description}
  Click Element   xpath=//input[@type="submit"]
  Wait Until Page Contains    Кандидат дискваліфікований. Зачекайте синхронізації   30
  Перевірити та сховати повідомлення

Завантажити угоду до тендера
  [ARGUMENTS]   ${username}  ${tender_uaid}  ${index}  ${file_path}
  Перейти на форму підписання контракту   ${username}  ${tender_uaid}
  Приєднати документ    id=fileInput2   ${file_path}

Перейти на форму підписання контракту
  [Arguments]   ${username}   ${tender_uaid}
  Зайти в розділ контракти
  ${drop_id}=  Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _pending
  ${action_id}=   Catenate   SEPARATOR=   ${UBIZ_LOT_ID}   _publish_contract
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Клацнути по випадаючому списку  ${drop_id}
  ...   AND   Element Should Be Visible   id=${action_id}
  Виконати дію   ${action_id}
  Wait Until Page Contains   Реєстрація контракту   10

Підтвердити підписання контракту
  [Arguments]   ${user_name}   ${tender_uaid}   ${index}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${is_contract_view}=   Run Keyword And Return Status    Element Should Not Be Visible   id=datetimepicker5
  Run Keyword If  ${is_contract_view}   Run Keywords
  ...   Перейти на форму підписання контракту   ${user_name}   ${tender_uaid}
  ...   AND  Приєднати документ    id=fileInput2   ${file_path}
  ${date}=   get_cur_date
  Input Text    id=OpContract_op_contract_number    111211111-21102121
  Input Text    id=datetimepicker5    ${date}
  Click Element   xpath=//input[@class="btn btn-primary bnt-lg pull-right"]
  Wait Until Page Contains   Договір знаходиться в стані очікування публікації в ЦБД   15
  Перевірити та сховати повідомлення
