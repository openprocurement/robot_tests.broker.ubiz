*** Settings ***
Library  String
Library  DateTime
Library  ubiz_service.py


*** Variables ***

${locator.auctionID}                                           css=.auction-auctionID
${locator.title}                                               css=.auction-title
${locator.status}                                              css=.auction-status
${locator.dgfID}                                               css=.auction-dgfId
${locator.procurementMethodType}                               css=.auction-procurementMethodType
${locator.description}                                         css=.auction-description
${locator.minimalStep.amount}                                  css=.auction-minimalStep-amount
${locator.procuringEntity.name}                                css=.auction-procuringEntity-name
${locator.value.amount}                                        css=.auction-value-amount
${locator.guarantee.amount}                                    css=.auction-guarantee-amount
${locator.value.currency}                                      css=.auction-value-currency
${locator.value.valueAddedTaxIncluded}                         css=.auction-value-tax
${locator.tenderPeriod.startDate}                              css=.tender-period-start
${locator.tenderPeriod.endDate}                                css=.tender-period-end
${locator.auctionPeriod.startDate}                             css=.auction-period-start
${locator.auctionPeriod.endDate}                               css=.auction-period-end
${locator.tenderAttempts}                                      css=.auction-tenderAttempts

${locator.qualificationPeriod.startDate}                        css=.award-period-start
${locator.qualificationPeriod.endDate}                          css=.award-period-end

${locator.enquiryPeriod.startDate}                             css=.enquiry-period-start
${locator.enquiryPeriod.endDate}                               css=.enquiry-period-end
${locator.cancellations[0].status}                             css=.cancellation-status
${locator.cancellations[0].reason}                             css=.cancellation-reason
${locator.awards[0].status}                                    css=.award-status-0
${locator.awards[1].status}                                    css=.award-status-1

*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  ${user_name}   ${auction_data}   ${role_name}
  ${auction_data}=   before_create_auction   ${auction_data}   ${role_name}
  [return]   ${auction_data}

Підготувати клієнт для користувача
  [Arguments]   ${username}
  Set Global Variable    ${MODIFICATION_DATE}   ${EMPTY}
  ${alias}=              Catenate   SEPARATOR=   role_  ${username}
  Set Global Variable    ${BROWSER_ALIAS}   ${alias}
  Open Browser           ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${BROWSER_ALIAS}
  Set Window Size        @{USERS.users['${username}'].size}
  Set Window Position    @{USERS.users['${username}'].position}
  Run Keyword If        '${username}' != 'ubiz_Viewer'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Page Contains Element    id=login-button
  Click Element                       id=login-button
  Wait Until Element Is Visible       id=login-form-login   30
  Input text                          xpath=//input[contains(@id, 'login-form-login')]   ${USERS.users['${username}'].login}
  Input text                          xpath=//input[contains(@id, 'login-form-password')]   ${USERS.users['${username}'].password}
  Click Element                       id=login-form-button
  Wait Until Page Contains Element    css=.logout   45

Створити тендер
  [Arguments]   ${user_name}   ${auction_data}
  ${procurementMethodType}=        Get From Dictionary   ${auction_data.data}   procurementMethodType
  ${tenderAttempts}=               Get From Dictionary   ${auction_data.data}   tenderAttempts
  ${title}=                        Get From Dictionary   ${auction_data.data}   title
  ${description}=                  Get From Dictionary   ${auction_data.data}   description
  ${dgfID}=                        Get From Dictionary   ${auction_data.data}   dgfID
  ${valueAmount}=                  Get From Dictionary   ${auction_data.data.value}   amount
  ${valueAddedTaxIncluded}=        Get From Dictionary   ${auction_data.data.value}   valueAddedTaxIncluded
  ${minimalStepAmount}=            Get From Dictionary   ${auction_data.data.minimalStep}   amount
  ${guaranteeAmount}=              Get From Dictionary   ${auction_data.data.guarantee}   amount
  ${auctionPeriodStartDate}=       Get From Dictionary   ${auction_data.data.auctionPeriod}   startDate

  ${nameContactPoint}=             Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   name
  ${emailContactPoint}=            Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   email
  ${faxNumberContactPoint}=        Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   faxNumber
  ${telephoneContactPoint}=        Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   telephone
  ${urlContactPoint}=              Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   url


  #Prepare
  ${procurementMethodType}=        cdb_format_to_view_format   ${procurementMethodType}
  ${tenderAttempts}=               Convert To String    ${tenderAttempts}
  ${tenderAttempts}=               cdb_format_to_view_format   ${tenderAttempts}
  ${valueAmount} =                 Convert To String   ${valueAmount}
  ${valueAddedTaxIncluded}         Convert To String   ${valueAddedTaxIncluded}
  ${valueAddedTaxIncluded}         Convert To Lowercase   ${valueAddedTaxIncluded}
  ${minimalStepAmount}=            Convert To String   ${minimalStepAmount}
  ${guaranteeAmount}=              Convert To String   ${guaranteeAmount}
  ${auctionPeriodStartDate}=       auction_period_to_broker_format   ${auctionPeriodStartDate}


  ${items}=                                Get From Dictionary   ${auction_data.data}   items
  ${number_of_items}=                      Get Length   ${items}
  ${isContainMinNumberOfQualifiedBids}=    Run Keyword And Return Status   Dictionary Should Contain Key  ${auction_data.data}  minNumberOfQualifiedBids
	${minNumberOfQualifiedBids}=                 Run Keyword If          ${isContainMinNumberOfQualifiedBids}
	...   Get From Dictionary                    ${auction_data.data}    minNumberOfQualifiedBids
	...   ELSE                                   Set Variable            2

	##====================== Продаж / Оренда ========================
	${is_lease}=          Set Variable    ${FALSE}
	:FOR  ${index}        IN RANGE        ${number_of_items}
	\  ${is_lease}=       Run Keyword And Return Status    Should Be Equal   ${items[${index}].additionalClassifications[0].id}   PA01-7
	\  Exit For Loop If   ${is_lease}
	\  ${is_lease}=       Run Keyword And Return Status    Should Be Equal   ${items[${index}].additionalClassifications[0].id}   PA02-0
	\  Exit For Loop If   ${is_lease}
	##====================== Продаж / Оренда ========================


  Wait Until Element Is Visible    id=add_auction
  Click Link                       id=add_auction
  Wait Until Page Contains         Створення аукціону
  ${subProcurementtype}=           cdb_format_to_view_format   sub_${is_lease}
  Run Keyword If   ${is_lease}     SelectBox   auction-subprocurementtype    ${subProcurementtype}
  Log To Console    ${subProcurementtype}
  Sleep    1
  ${minNumberOfQualifiedBids}=     cdb_format_to_view_format   bidder${minNumberOfQualifiedBids}
  Run Keyword If   ${is_lease}     SelectBox   auction-minnumberbids    ${minNumberOfQualifiedBids}

  SelectBox                        auction-tenderattempts   ${tenderAttempts}
  Input Text                       id=auction-title    ${title}
  Input Text                       id=auction-description    ${description}
  Input Text                       id=auction-dgfid    ${dgfID}
  Input Text                       id=Auction-value-amount   ${valueAmount}
  SwitchBox                        Auction-value-valueAddedTaxIncluded   ${valueAddedTaxIncluded}
  Input Text                       id=Auction-minimalStep-amount   ${minimalStepAmount}
  Input Text                       id=Auction-guarantee-amount   ${guaranteeAmount}
  Execute JavaScript               $('#auction-auctionperiod-startdate-disp').removeAttr('readonly');
  Input Text                       id=auction-auctionperiod-startdate-disp   ${auctionPeriodStartDate}
  Input Text                       id=contactPerson-name   ${nameContactPoint}
  Input Text                       id=contactPerson-telephone   ${telephoneContactPoint}
  Input Text                       id=contactPerson-faxNumber   ${faxNumberContactPoint}
  Input Text                       id=contactPerson-email   ${emailContactPoint}
  Input Text                       id=contactPerson-url   ${urlContactPoint}
  Scroll To Element                .box-footer
  Click Element                    xpath=//button[contains(text(), 'Далі')]

   #Items part
  Додати активи                    ${items}
  Click Link                       id=endEdit
  Wait Until Page Contains         Чернетки
  Дія з аукціоном-чернеткою        draft-publication
  Wait Until Keyword Succeeds   4 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Очікування публікації
  Click Link                        css=.auction-draft-status
  Wait Until Element Is Visible     css=.auction-auctionID
  ${auctionID}=                     Get Text   css=.auction-auctionID
  [return]                          ${auctionID}

Очікування публікації
  ${publicationStatus}=   Get Text   css=.auction-draft-status
  Should Be Equal   '${publicationStatus}'   'Опубліковано'

Класифікатор
  [Arguments]   ${classificationId}    ${scheme}
  Click Link                          css=.classifications
  Wait Until Element Is Visible       id=classificationsearch-code
  ${scheme}=                          cdb_format_to_view_format   ${scheme}
  Select From List By Value           id=classificationsearch-scheme    ${scheme}
  Sleep    1
  Input Text                          id=classificationsearch-code   ${classificationId}
  Click Element                       id=classification-search-find
  Wait Until Page Contains Element    xpath=//tr[contains(@data-classification, '${classificationId}')]
  Sleep    1
  Click Element                       xpath=//tr[contains(@data-classification, '${classificationId}')]
  Wait Until Element Is Visible       id=save-and-hide-modal-btn
  Click Element                       id=save-and-hide-modal-btn
  Sleep    2

Додати актив
  [Arguments]   ${item}
  ${description}=                 Get From Dictionary   ${item}   description
  ${quantity}=                    Get From Dictionary   ${item}   quantity
  ${unitName}=                    Get From Dictionary   ${item.unit}   name
  ${classificationId}=            Get From Dictionary   ${item.classification}   id
  ${classificationScheme}=        Get From Dictionary   ${item.classification}   scheme

  ${quantity}=                    Convert To String   ${quantity}

  Період дії договору оренди      ${item}

  Input Text                      id=item-description   ${description}
  Input Text                      id=item-quantity   ${quantity}
  SelectBox                       item-unitid   ${unitName}
  Класифікатор                    ${classificationId}   ${classificationScheme}
  Scroll To Element               .box-footer
  Click Element                   xpath=//button[contains(text(), 'Зберегти')]
  Wait Until Element Is Visible   id=endEdit   30

Заповнити період оренди
  [Arguments]   ${locator}   ${value}
  Execute JavaScript   $('#${locator}').removeAttr('readonly');
  ${value}=            contract_period   ${value}
  Input Text           id=${locator}   ${value}
  Sleep                1

Період дії договору оренди
  [Arguments]   ${item}
  ${isExistStartDate}=   Run Keyword And Return Status   Dictionary Should Contain Key  ${item.contractPeriod}  startDate
  ${isExistEndDate}=     Run Keyword And Return Status   Dictionary Should Contain Key  ${item.contractPeriod}  endDate
  Run Keyword If    ${isExistStartDate}   Заповнити період оренди   item-contractperiod-startdate-disp    ${item.contractPeriod.startDate}
  Run Keyword If    ${isExistEndDate}     Заповнити період оренди   item-contractperiod-enddate-disp      ${item.contractPeriod.endDate}

На форму додавання активу
  ${addItem}=   Run Keyword And Return Status   Page Should Contain Element   xpath=//a[contains(text(), 'Додати актив')]
  Run Keyword If   ${addItem}   Click Element   xpath=//a[contains(text(), 'Додати актив')]
  Wait Until Element Is Visible   id=item-description   15

Додати активи
  [Arguments]   ${items}
  ${count}=   Get Length   ${items}
  : FOR    ${index}    IN RANGE   ${count}
  \   На форму додавання активу
  \   Додати актив   ${items[${index}]}

Клацнути і дочекатися
    [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
    [Documentation]
    ...      click_locator: Where to click
    ...      wanted_locator: What are we waiting for
    ...      timeout: Timeout
    Click Element  ${click_locator}
    Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
  [Arguments]   ${auction_id}
  Input Text                           id=main-auctionsearch-title   ${auction_id}
  Click Element                        id=search-main
  Wait Until Page Contains Element     xpath=//span[contains(text() ,'ID аукціону ${auction_id}')]   10
  Sleep                                 5

Пошук тендера по ідентифікатору
  [Arguments]   ${user_name}   ${auction_id}
  Switch Browser   ${BROWSER_ALIAS}
  На початок сторінки
  ${isAuctionView}=                   Run Keyword And Return Status   Page Should Contain Element   xpath=//a[@href='#parameters']
  Return From Keyword If              ${isAuctionView}   ${TRUE}
  Wait Until Page Contains Element    id=main-auctionsearch-title   45
  ${timeout_on_wait}=                 Get Broker Property By Username  ${user_name}  timeout_on_wait
  ${passed}=                          Run Keyword And Return Status   Wait Until Keyword Succeeds   6 x  ${timeout_on_wait} s  Шукати і знайти   ${auction_id}
  Run Keyword Unless   ${passed}      Fail   Аукціо не знайдено за ${timeout_on_wait} секунд
  ${url}=                             Get Element Attribute   xpath=//div[contains(@class, 'one_card')]//a[contains(@class, 'auction-view')]@href
  Execute JavaScript                  window.location.href = '${url}';
  Wait Until Page Contains Element    xpath=//a[@href='#parameters']   45
  На початок сторінки

На початок сторінки
  Execute JavaScript     $(window).scrollTop(0);
  Sleep    1

Пошук тендера у разі наявності змін
  [Arguments]   ${last_mod_date}   ${user_name}   ${auction_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  ${status}=             Run Keyword And Return Status   Should Not Be Equal   ${MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword If         ${status}   Run Keyword And Ignore Error   Click Link   css=.auction-reload
  Set Global Variable    ${MODIFICATION_DATE}   ${last_mod_date}

Завантажити документ в тендер з типом
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}   ${document_type}=${EMPTY}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ продаю
  Дія з аукціоном                    auction-documents
  Wait Until Page Contains Element   id=documents-box-auctionDocuments   30
  Розгорнути блоки
  Sleep                              2
  Click Element                      xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Sleep                              2
  ${addedBlock}=                     Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Choose File                        xpath=//div[@id='${addedBlock}']//input[@class='document-img']   ${file_path}
  Wait Until Page Contains           Done    30
  Run Keyword If                     '${document_type}' != '${EMPTY}'   Select From List By Value   xpath=//div[@id='${addedBlock}']//select  ${document_type}
  Click Element                      xpath=//button[contains(text(), 'Заватажити')]

Отримати кількість предметів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${number_of_items}=  Get Matching Xpath Count  //div[contains(@class,'item_description')]
  [return]  ${number_of_items}

Завантажити документ
  [Arguments]  ${user_name}   ${file_path}   ${auction_id}
  ubiz.Завантажити документ в тендер з типом   ${user_name}   ${auction_id}   ${file_path}


Змінити документ в ставці
  [Arguments]   ${username}   ${tender_uaid}    ${path}   ${docid}
  Fail    Після відправки заявки оператору майданчика  - змінити доки неможливо

Ввести цінову пропозицію
   [Arguments]   ${valueAmount}
   ${valueAmountToString}=   Convert To String   ${valueAmount}
   Input text                id=Bid-value-amount   ${valueAmountToString}

Чи фінасова процедура
  ${procurementMethodType}=       Get Text    css=.auction-procurementMethodType
  ${isOther}=                     Run Keyword And Return Status   Should Be Equal   '${procurementMethodType}'     'Майно банку'
  Return From Keyword If          ${isOther}   ${FALSE}
  ${isFinancial}=                 Run Keyword And Return Status   Should Be Equal   '${procurementMethodType}'     'Право вимоги'
  Return From Keyword If          ${isFinancial}    ${isFinancial}
  ${subProcurementMethodType}=    Get Text    css=.auction-dutchProcurementMethodType
  ${dutchIsFinancial}=            Run Keyword And Return Status   Should Be Equal   '${subProcurementMethodType}'  'Права вимоги'
  [return]                        ${dutchIsFinancial}

Прикріпити фейковий док до пропозиції
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Завантажити один документ   ${file_path}

Подати цінову пропозицію
  [Arguments]   ${user_name}   ${auction_id}   ${bid_data}
  ${qualified}=                   Get From Dictionary   ${bid_data.data}   qualified
  Run Keyword And Return If       ${qualified} == ${FALSE}   Fail   Учасник не кваліфікований
  ubiz.Пошук тендера по ідентифікатору            ${user_name}   ${auction_id}
  ${isFinancialProcedure}         Run Keyword   Чи фінасова процедура
  Click Link                      css=.auction-bid-create
  Wait Until Page Contains        ПОДАЧА ЦІНОВОЇ ПРОПОЗИЦІЇ
  Scroll To Element               .container
  ${isExistValueAmount}=          Run Keyword And Return Status   Dictionary Should Contain Key  ${bid_data.data}   value
  Run Keyword If                  ${isExistValueAmount}   Ввести цінову пропозицію   ${bid_data.data.value.amount}
  Run Keyword If                  ${isFinancialProcedure}   Прикріпити фейковий док до пропозиції
  Execute JavaScript              $('input[id*=bid-condition]').trigger('click');
  Click Element                   xpath=//button[contains(text(), 'Зберегти')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), 'Купую')]
  Run Keyword If                  ${isFinancialProcedure} == ${FALSE}   Дія з пропозицією   bid-publication

Дія з пропозицією
  [Arguments]   ${class}
  Execute JavaScript              $('.one_card').first().find('.fa-angle-down').click();
  Wait Until Element Is Visible   css=.${class}
  Click Link                      css=.${class}

Завантажити фінансову ліцензію
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ купую
  Дія з пропозицією                  bid-edit
  Wait Until Page Contains Element   css=.document-img
  Scroll To Element                  .tab-content
  Choose File                        css=.document-img   ${file_path}
  Wait Until Page Contains           Done
  Click Element                      xpath=//button[contains(text(), 'Зберегти')]
  Wait Until Element Is Visible      xpath=//p[contains(text(), 'Купую')]
  Дія з пропозицією                  bid-publication

Завантажити документ в ставку
  [Arguments]  ${user_name}  ${file_path}  ${auction_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ купую
  Дія з пропозицією   bid-edit
  Wait Until Page contains        ПОДАЧА ЦІНОВОЇ ПРОПОЗИЦІЇ   45
  Click Element                   xpath=//button[contains(text(), 'Зберегти')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), 'Купую')]


Перейти в розділ купую
  Click Element                   id=category-select
  Wait Until Element Is Visible   xpath=//a[contains(text(), 'Купую')]
  Click Link                      xpath=//a[contains(text(), 'Купую')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), 'Купую')]

Перейти в розділ продаю
  Click Element                   id=category-select
  Wait Until Element Is Visible   xpath=//a[contains(text(), 'Продаю')]
  Click Link                      xpath=//a[contains(text(), 'Продаю')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), 'Продаю')]

Дія з аукціоном-чернеткою
  [Arguments]   ${class}
  Execute JavaScript              $('.one_card').first().find('.fa-angle-down').click();
  Wait Until Element Is Visible   css=.${class}
  Click Link                      css=.${class}

Дія з аукціоном
  [Arguments]   ${class}
  Execute JavaScript              $('.one_card').first().find('.fa-angle-down').click();
  Wait Until Element Is Visible   css=.${class}
  Click Link                      css=.${class}

Скасувати цінову пропозицію
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ купую
  Дія з пропозицією        bid-cancellation

Отримати інформацію із пропозиції
  [Arguments]   ${user_name}   ${auction_id}   ${field}
  ubiz.Пошук тендера по ідентифікатору       ${user_name}   ${auction_id}
  Перейти в розділ купую
  ${bidValueAmount}=         Get Text   css=.bid-value-amount
  ${bidValueAmount}=         Convert To Number   ${bidValueAmount}
  [return]                   ${bidValueAmount}

Закрити модальне вікно
  Execute JavaScript   $('.close').trigger('click');
  Sleep    1

Змінити цінову пропозицію
  [Arguments]   ${user_name}   ${auction_id}   ${field}   ${value}
  ubiz.Пошук тендера по ідентифікатору            ${user_name}   ${auction_id}
  Click Element                   css=.bid-change-value-amount
  Wait Until Element Is Visible   id=BidChangeValueAmount-value-amount
  ${valueAmountToString}=         Convert To String   ${value}
  Input Text                      id=BidChangeValueAmount-value-amount   ${valueAmountToString}
  Click Element                   xpath=//button[contains(text(), 'Змінити цінову пропозицію')]
  Wait Until Page Contains        Пропозиція успішно оновлена   30
  Закрити модальне вікно

Оновити сторінку з тендером
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}


Задати запитання на тендер
  [Arguments]   ${user_name}   ${auction_id}   ${question_data}
  ${title}=                       Get From Dictionary  ${question_data.data}  title
  ${description}=                 Get From Dictionary  ${question_data.data}  description
  ubiz.Пошук тендера по ідентифікатору            ${user_name}   ${auction_id}
  Wait Until Element Is Visible   css=.auction-question-create
  Click Link                      css=.auction-question-create
  Wait Until Element Is Visible   id=question-title   30
  ${auctionTitle}=                Get Text    xpath=//a[contains(@class, 'text-justify')]
  SelectBox                       question-element   ${auctionTitle}
  Input text                      id=question-title   ${title}
  Input text                      id=question-description   ${description}
  Click Element                   xpath=//button[contains(text(), 'Запитати')]
  Wait Until Page Contains        Параметри аукціону   45

Задати запитання на предмет
  [Arguments]   ${user_name}   ${auction_id}   ${item_id}   ${question_data}
  ${title}=                       Get From Dictionary  ${question_data.data}  title
  ${description}=                 Get From Dictionary  ${question_data.data}  description
  ubiz.Пошук тендера по ідентифікатору            ${user_name}   ${auction_id}
  Wait Until Element Is Visible   css=.auction-question-create
  Click Link                      css=.auction-question-create
  Wait Until Element Is Visible   id=question-title   30
  Execute JavaScript              $("#question-element").val($("#question-element :contains('${item_id}')").last().attr("value")).change();
  Input text                      id=question-title   ${title}
  Input text                      id=question-description   ${description}
  Click Element                   xpath=//button[contains(text(), 'Запитати')]
  Wait Until Page Contains        Параметри аукціону   45

Відповісти на запитання
  [Arguments]   ${user_name}   ${auction_id}  ${answer_data}   ${question_id}
  ubiz.Пошук тендера по ідентифікатору            ${user_name}   ${auction_id}
  Таб Запитання
  ${answer}=                      Get From Dictionary  ${answer_data.data}   answer
  Wait Until Page Contains        ${question_id}
  Click Element                   xpath=//div[contains(@data-question-title, '${question_id}')]//a[contains(@class, 'question-answer')]
  Wait Until Element Is Visible   id=question-answer
  Input Text                      id=question-answer   ${answer}
  Click Element                   xpath=//button[contains(text(), 'Надати відповідь')]
  Wait Until Page Contains        Параметри аукціону   45

Отримати інформацію із тендера
  [Arguments]   ${user_name}   ${auction_id}   ${field}
  ubiz.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  Run Keyword And Return   Отримати інформацію про ${field}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${field}
  Wait Until Page Contains Element   ${locator.${field}}    30
  ${value}=                          Get Text   ${locator.${field}}
  [return]                           ${value}

Отримати інформацію про status
  Reload Page
  ${status}=   Отримати текст із поля і показати на сторінці   status
  ${status}=   view_to_cdb_fromat   ${status}
  [return]     ${status}

Отримати інформацію про dgfDecisionID
  ${dgfDecisionID}=   Отримати текст із поля і показати на сторінці   dgfDecisionID
  [return]            ${dgfDecisionID}

Отримати інформацію про dgfDecisionDate
  ${dgfDecisionDate}=   Отримати текст із поля і показати на сторінці   dgfDecisionDate
  ${dgfDecisionDate}=   convert_date_to_dash_format   ${dgfDecisionDate}
  [return]              ${dgfDecisionDate}

Отримати інформацію про eligibilityCriteria
  ${return_value}=   Отримати текст із поля і показати на сторінці   eligibilityCriteria
  [return]           ${return_value}

Отримати інформацію про procurementMethodType
  ${procurementMethodType}=   Отримати текст із поля і показати на сторінці   procurementMethodType
  ${procurementMethodType}=   view_to_cdb_fromat   ${procurementMethodType}
  [return]                    ${procurementMethodType}

Отримати інформацію про dgfID
  ${dgfID}=   Отримати текст із поля і показати на сторінці   dgfID
  [return]    ${dgfID}

Отримати інформацію про title
  ${title}=   Отримати текст із поля і показати на сторінці   title
  [return]    ${title}

Отримати інформацію про description
  ${description}=   Отримати текст із поля і показати на сторінці   description
  [return]          ${description}

Отримати інформацію про minimalStep.amount
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про розмір ставки
  ${return_value}=   Отримати текст із поля і показати на сторінці   mybid
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про value.amount
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про guarantee.amount
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  guarantee.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про auctionID
  ${auctionID}=   Отримати текст із поля і показати на сторінці   auctionID
  [return]        ${auctionID}

Отримати інформацію про value.currency
  Таб Параметри аукціону
  ${currency}=   Отримати текст із поля і показати на сторінці   value.currency
  ${currency}=   view_to_cdb_fromat   ${currency}
  [return]       ${currency}

Отримати інформацію про value.valueAddedTaxIncluded
  Таб Параметри аукціону
  ${tax}=    Отримати текст із поля і показати на сторінці   value.valueAddedTaxIncluded
  ${tax}=    view_to_cdb_fromat   ${tax}
  ${tax}=    Convert To Boolean   ${tax}
  [return]   ${tax}

Отримати інформацію про procuringEntity.name
  ${procuringEntityName}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]                  ${procuringEntityName}

Отримати інформацію про tenderAttempts
  Таб Параметри аукціону
  ${tenderAttempts}=   Отримати текст із поля і показати на сторінці   tenderAttempts
  ${tenderAttempts}=   view_to_cdb_fromat   ${tenderAttempts}
  [return]             ${tenderAttempts}

Отримати інформацію про auctionPeriod.startDate
  Таб Параметри аукціону
  ${startDate}=   Отримати текст із поля і показати на сторінці    auctionPeriod.startDate
  ${startDate}=   subtract_from_time   ${startDate}  0   0
  [return]        ${startDate}

Отримати інформацію про auctionPeriod.endDate
  Таб Параметри аукціону
  Wait Until Keyword Succeeds   15 x   40 s   Run Keywords
  ...   Reload Page
  ...   AND   Таб Параметри аукціону
  ...   AND   Element Should Be Visible   css=.auction-period-end
  ${endDate}=   Отримати текст із поля і показати на сторінці   auctionPeriod.endDate
  ${endDate}=   subtract_from_time   ${endDate}   0   0
  [return]      ${endDate}

Отримати інформацію про tenderPeriod.startDate
  Таб Параметри аукціону
  ${startDate}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${startDate}=   subtract_from_time    ${startDate}   0   0
  [return]        ${startDate}

Отримати інформацію про tenderPeriod.endDate
  Таб Параметри аукціону
  ${endDate}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${endDate}=   subtract_from_time   ${endDate}  0  0
  [return]      ${endDate}

Отримати інформацію про qualificationPeriod.startDate
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.startDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]           ${return_value}

Отримати інформацію про qualificationPeriod.endDate
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.endDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]           ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  Fail  enquiryPeriod відсутній

Отримати інформацію про enquiryPeriod.endDate
  Fail  enquiryPeriod відсутній

Отримати інформацію із предмету
  [Arguments]   ${user_name}   ${auction_id}   ${item_id}   ${field}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Таб Активи аукціону
  Wait Until Element Is Visible   xpath=//a[contains(text(), '${item_id}')]
  Click Link                      xpath=//a[contains(text(), '${item_id}')]
  Wait Until Element Is Visible   xpath=//div[contains(@data-item-description, '${item_id}')]
  ${fieldValue}=                  Get Text   xpath=//div[contains(@data-item-description, '${item_id}')]//*[contains(@class, 'item-${field.replace('.','-').replace('code','name')}')]
  ${fieldValue}=                  adapt_items_data   ${field}   ${fieldValue}
  [return]                        ${fieldValue}

Отримати посилання на аукціон для глядача
  [Arguments]   ${user_name}   ${auction_id}   ${lot_id}=${Empty}
  Run Keyword And Return   Отримати посилання на аукціон   ${user_name}   ${auction_id}   auction-url

Отримати посилання на аукціон для учасника
  [Arguments]   ${user_name}   ${auction_id}   ${lot_id}=${Empty}
  Run Keyword And Return   Отримати посилання на аукціон   ${user_name}   ${auction_id}   bidder-url

Отримати посилання на аукціон
  [Arguments]   ${user_name}   ${auction_id}   ${auctionOrBidderUrl}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   css=.${auctionOrBidderUrl}
  Run Keyword And Return    Get Element Attribute   css=.${auctionOrBidderUrl}@href

Скролл до табів
  Scroll To Element    .nav-tabs-ubiz

Завантажити протокол аукціону
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}   ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ купую
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Дія з пропозицією    bid-award-protocol
  Wait Until Page Contains         Завантаження протоколу аукціону
  Завантажити один документ        ${file_path}
  Click Element                    xpath=//button[contains(text(), 'Завантажити')]

Завантажити ілюстрацію
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}
  ubiz.Завантажити документ в тендер з типом   ${user_name}   ${auction_id}   ${file_path}   illustration

Додати публічний паспорт активу
  [Arguments]   ${user_name}   ${auction_id}  ${certificate_url}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ продаю
  Дія з аукціоном                       auction-documents
  Wait Until Page Contains Element      id=documents-box-auctionDocuments   30
  Розгорнути блоки
  Sleep                                 2
  Click Element                         xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Sleep                                 2
  ${addedBlock}=                        Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value             xpath=//div[@id='${addedBlock}']//select   x_dgfPublicAssetCertificate
  Wait Until Page Contains Element      xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]    10
  Input text                            xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]   ${certificate_url}
  Click Element                         xpath=//button[contains(text(), 'Заватажити')]

Додати офлайн документ
  [Arguments]  ${user_name}  ${auction_id}  ${accessDetails}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ продаю
  Дія з аукціоном                       auction-documents
  Wait Until Page Contains Element      id=documents-box-auctionDocuments   30
  Розгорнути блоки
  Sleep                                 2
  Click Element                         xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Sleep                                 2
  ${addedBlock}=                        Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value             xpath=//div[@id='${addedBlock}']//select    x_dgfAssetFamiliarization
  Wait Until Page Contains Element      xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]    10
  Input text                            xpath=//div[@id='${addedBlock}']//textarea[contains(@name, 'textDocument')]   ${accessDetails}
  Click Element                         xpath=//button[contains(text(), 'Заватажити')]

Отримати інформацію із запитання
  [Arguments]   ${user_name}   ${auction_id}   ${question_id}   ${field}
  ubiz.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Таб Запитання
  ...   AND   Page Should Contain   ${question_id}
  ${fieldValue}=    Get Text   xpath=//div[contains(@data-question-title, '${question_id}')]//*[contains(@class, 'question-${field}')]
  [return]          ${fieldValue}

Отримати інформацію із документа по індексу
  [Arguments]   ${user_name}   ${auction_id}   ${document_index}   ${field}
  ubiz.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  Таб Документи
  Wait Until Element Is Visible         id=auction-docs
  ${text}=                              Get Text   css=.document-documentType
  ${text}=                              view_to_cdb_fromat   ${text}
  [return]                              ${text}

Отримати інформацію із документа
  [Arguments]   ${user_name}   ${auction_id}   ${document_id}   ${field}
  ubiz.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  ${currentStatus}=               Get Text   css=.auction-status
  ${wasCancelled}=                Run Keyword And Return Status   Should Be Equal   ${currentStatus}   СКАСОВАНИЙ
  Run Keyword If   ${wasCancelled}   Таб Скасування
  ...   ELSE    Таб Документи
  ${fieldValue}=                  Get Text   xpath=//div[contains(@data-document-title, '${document_id}')]//*[contains(@class, 'document-${field}')]
  [return]                        ${fieldValue}

Отримати документ
  [Arguments]   ${user_name}   ${auction_id}   ${document_id}
  ubiz.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${user_name}   ${auction_id}
  Таб Документи
  Wait Until Element Is Visible   id=auction-docs
  ${fileName}=                    Get Text   xpath=//div[contains(@data-document-title, '${document_id}')]//a
  ${fileUrl}=                     Get Element Attribute   xpath=//div[contains(@data-document-title, '${document_id}')]//a@href
  ${fileName}=                    download_file_from_url  ${fileUrl}  ${OUTPUT_DIR}${/}${fileName}
  [return]                        ${fileName}

Розгорнути блоки
  Execute JavaScript   $('.fa-plus').trigger('click');
  Sleep    2

Завантажити один документ
  [Arguments]   ${file_path}
  Розгорнути блоки
  Wait Until Page Contains Element   css=.add-item
  Click Element                      css=.add-item
  Wait Until Page Contains Element   css=.document-img
  Choose File                        css=.document-img   ${file_path}
  Wait Until Page Contains           Done

Скасувати закупівлю
  [Arguments]   ${user_name}   ${auction_id}   ${reason}   ${file_path}   ${description}
  ubiz.Пошук тендера по ідентифікатору               ${user_name}   ${auction_id}
  Click Link                         css=.auction-cancellation
  Wait Until Page Contains           Скасування аукціону   45
  Scroll To Element                  .container
  SelectBox                          cancellation-reason   ${reason}
  Завантажити один документ          ${file_path}
  Click Element                      xpath=//button[contains(text(), 'Скасувати')]
  Wait Until Page Contains Element   xpath=//a[@href='#cancellations']   45

Отримати інформацію про awards[0].status
  Таб Кваліфікація
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards[0].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

Отримати інформацію про awards[1].status
  Таб Кваліфікація
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards[1].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

Отримати інформацію про cancellations[0].status
  Таб Скасування
  ${return_value}=   Отримати текст із поля і показати на сторінці   cancellations[0].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

Отримати інформацію про cancellations[0].reason
  Таб Скасування
  ${return_value}=   Отримати текст із поля і показати на сторінці   cancellations[0].reason
  [return]           ${return_value}

Отримати кількість документів в тендері
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Таб Документи
  ${countDocuments}=     Get Matching Xpath Count   xpath=//p[contains(@class,'document-datePublished')]
  [return]               ${countDocuments}

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
  [Arguments]  ${username}   ${tender_uaid}   ${bid_index}   ${document_index}   ${field}
  ${fileid_index}=   Catenate   SEPARATOR=   ${field}   ${document_index}
  ${doc_value}=      Get Text   xpath=//span[contains(@class, '${fileid_index}')]
  ${doc_value}=      view_to_cdb_fromat   ${doc_value}
  [return]           ${doc_value}

Завантажити документ рішення кваліфікаційної комісії
  [ARGUMENTS]   ${user_name}   ${file_path}  ${auction_id}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Таб Кваліфікація
  Wait Until Page Contains Element     css=.award-disqualification
  Click Link                           css=.award-disqualification
  Wait Until Page Contains             Дискваліфікація учасника   30
  Input Text                           id=disqualification-title   Дискваліфікація учасника
  Input Text                           id=disqualification-description   ${description}
  ${withDocuments}=                    Run Keyword And Return Status    Page Should Contain Element   id=documents-box
  Run Keyword If   ${withDocuments}    Завантажити один документ   ${file_path}

Дискваліфікувати постачальника
  [Arguments]   ${user_name}   ${auction_id}  ${award_index}  ${description}
  Wait Until Page Contains Element      xpath=//button[contains(text(), 'Дискваліфікувати')]
  Click Element                         xpath=//button[contains(text(), 'Дискваліфікувати')]
  Wait Until Page Contains Element      xpath=//a[@href='#parameters']   45

Завантажити угоду до тендера
  [Arguments]   ${user_name}   ${auction_id}   ${contract_index}   ${file_path}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Таб Контракт
  Wait Until Page Contains Element     css=.contract-publication
  Click Link                           css=.contract-publication
  Wait Until Page Contains             Публікація договору   45
  Завантажити один документ            ${file_path}

Підтвердити підписання контракту
  [Arguments]   ${user_name}   ${auction_id}   ${contract_index}
  Wait Until Page Contains Element   xpath=//button[contains(text(), 'Опублікувати')]
  Click Element                      xpath=//button[contains(text(), 'Опублікувати')]
  Wait Until Page Contains Element   xpath=//a[@href='#parameters']   45

Завантажити протокол аукціону в авард
  [Arguments]   ${user_name}   ${auction_id}   ${file_path}   ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Таб Кваліфікація
  Wait Until Page Contains Element    css=.award-upload-protocol
  Click Link                          css=.award-upload-protocol
  Wait Until Page Contains            Завантаження протоколу аукціону   30
  Завантажити один документ           ${file_path}

Підтвердити наявність протоколу аукціону
  [Arguments]   ${user_name}   ${auction_id}   ${award_index}
  Wait Until Page Contains Element   xpath=//button[contains(text(), 'Завантажити')]
  Click Element                      xpath=//button[contains(text(), 'Завантажити')]
  Wait Until Page Contains Element   xpath=//a[@href='#parameters']   45

Підтвердити постачальника
  [Arguments]   ${user_name}   ${auction_id}   ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Таб Кваліфікація
  Wait Until Page Contains Element    css=.award-activation
  Click Link                          css=.award-activation
  Wait Until Page Contains Element    xpath=//a[@href='#parameters']   45

Скасування рішення кваліфікаційної комісії
  [Arguments]   ${user_name}   ${auction_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${auction_id}
  Перейти в розділ купую
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Дія з пропозицією    bid-award-cancellation

Таб Параметри аукціону
  Скролл до табів
  Click Link            xpath=//a[@href='#parameters']

Таб Активи аукціону
  Скролл до табів
  Click Link            xpath=//a[@href='#items']

Таб Документи
  Скролл до табів
  Click Link            xpath=//a[@href='#documents']

Таб Запитання
  Скролл до табів
  Click Link            xpath=//a[@href='#questions']

Таб Пропозиції
  Скролл до табів
  Click Link            xpath=//a[@href='#bids']

Таб Кваліфікація
  Скролл до табів
  Розгорнути блоки
  Click Link            xpath=//a[@href='#awards']

Таб Контракт
  Скролл до табів
  Click Link            xpath=//a[@href='#contracts']

Таб Скасування
  Скролл до табів
  Розгорнути блоки
  Click Link            xpath=//a[@href='#cancellations']

SelectBox
  [Arguments]   ${select_id}   ${text}
  Execute JavaScript   $("#${select_id}").val($("#${select_id} :contains('${text}')").first().attr("value")).change();

SwitchBox
  [Arguments]   ${checkbox_id}   ${bool}
  Execute JavaScript   $("#${checkbox_id}").bootstrapSwitch('state', ${bool}, true).trigger('switchChange.bootstrapSwitch');

Scroll To Element
  [Arguments]   ${selector}
  Execute JavaScript   var targetOffset = $('${selector}').offset().top; $('html, body').animate({scrollTop: targetOffset}, 1000);
  Sleep    2

Змінити ціновий показник
  [Arguments]   ${locator}   ${value}
  ${value}=     Convert To String   ${value}
  Input Text    id=Edit-${locator}   ${value}

Внести зміни в тендер
  [Arguments]  ${user_name}  ${auction_id}  ${field}  ${value}
  ubiz.Пошук тендера по ідентифікатору    ${user_name}  ${auction_id}
  Перейти в розділ продаю
  Дія з аукціоном                    auction-edit
  Wait Until Page Contains Element   id=Edit-value-amount   15
  Змінити ціновий показник    ${field.replace('.', '-')}    ${value}
  Click Element               xpath=//button[contains(text(), 'Оновити')]
  Wait Until Page Contains    Продаю
