*** Settings ***
Library  String
Library  DateTime
Library  ubiz_service.py
Library  Collections

*** Variables ***

${locator.tenderId}                                            id=tenderId
${locator.title}                                               id=tenderTitle
${locator.title_en}                                            id=tenderTitleEn
${locator.description}                                         id=tenderDescription
${locator.description_en}                                      id=tenderDescriptionEn
${locator.cause}                                               id=tenderCause
${locator.causeDescription}                                    id=tenderCauseDescription
${locator.minimalStep.amount}                                  id=tenderMinimalStepAmount

${locator.procuringEntity.name}                                id=procuringEntityName

${locator.procuringEntity.address.countryName}                 id=procuringEntityAddressCountryName
${locator.procuringEntity.address.region}                      id=procuringEntityAddressRegion
${locator.procuringEntity.address.locality}                    id=procuringEntityAddressLocality
${locator.procuringEntity.address.streetAddress}               id=procuringEntityAddressStreetAddress
${locator.procuringEntity.address.postalCode}                  id=procuringEntityAddressPostalCode

${locator.awards.suppliers.name}                               css=.award-suppliers-name
${locator.awards.status}                                       css=.award-status
${locator.contracts.status}                                    css=.contract-status
${locator.awards.complaintPeriod.startDate}                    css=.awardComplaintPeriodStart
${locator.awards.complaintPeriod.endDate}                      css=.awardComplaintPeriodEnd
${locator.awards.value.amount}                                 css=.award-value-amount
${locator.awards.value.currency}                               css=.award-value-currency

${locator.award.suppliers.identifier.scheme}                   css=.award-suppliers-identifier-scheme
${locator.award.suppliers.identifier.id}                       css=.award-suppliers-identifier-id

${locator.awards.suppliers.address.countryName}                css=.award-suppliers-address-countryName
${locator.awards.suppliers.address.region}                     css=.award-suppliers-address-region
${locator.awards.suppliers.address.locality}                   css=.award-suppliers-address-locality
${locator.awards.suppliers.address.streetAddress}              css=.award-suppliers-address-streetAddress
${locator.awards.suppliers.address.postalCode}                 css=.award-suppliers-address-postalCode

${locator.awards.suppliers.contactPoint.name}                  css=.award-suppliers-contactPoint-name
${locator.awards.suppliers.contactPoint.telephone}             css=.award-suppliers-contactPoint-telephone
${locator.awards.suppliers.contactPoint.email}                 css=.award-suppliers-contactPoint-email

${locator.procuringEntity.contactPoint.name}                   id=procuringEntityContactPointName
${locator.procuringEntity.contactPoint.telephone}              id=procuringEntityContactPointTelephone
${locator.procuringEntity.contactPoint.url}                    id=procuringEntityContactPointUrl

${locator.procuringEntity.identifier.legalName}                id=procuringEntityIdentifierLegalName
${locator.procuringEntity.identifier.scheme}                   id=procuringEntityIdentifierScheme
${locator.procuringEntity.identifier.id}                       id=procuringEntityIdentifierId

${locator.value.valueAddedTaxIncluded}                         id=tenderValueTax
${locator.value.amount}                                        id=tenderValueAmount
${locator.value.currency}                                      id=tenderValueCurrency

${locator.tenderPeriod.startDate}                              id=tenderPeriodStart
${locator.tenderPeriod.endDate}                                id=tenderPeriodEnd

${locator.enquiryPeriod.startDate}                             id=enquiryPeriodStart
${locator.enquiryPeriod.endDate}                               id=enquiryPeriodEnd

${locator.qualificationPeriod.endDate}                         id=qualificationPeriodEnd

${locator.items.deliveryAddress.streetAddress}                 address
${locator.items.deliveryAddress.locality}                      locality
${locator.items.deliveryAddress.region}                        region
${locator.items.deliveryAddress.postalCode}                    postal_code
${locator.items.deliveryAddress.countryName}                   country

${locator.items.deliveryLocation.longitude}                    delivery-location-longitude
${locator.items.deliveryLocation.latitude}                     delivery-location-latitude
${locator.items.deliveryDate.startDate}                        delivery-start-date
${locator.items.deliveryDate.endDate}                          delivery-end-date
${locator.items.classification.id}                             classification-id
${locator.items.classification.description}                    classification-description
${locator.items.classification.scheme}                         classification-scheme
${locator.items.additionalClassifications[0].id}               classification-id-additional
${locator.items.additionalClassifications[0].description}      classification-description-additional
${locator.items.additionalClassifications[0].scheme}           classification-scheme-additional
${locator.items.unit.name}                                     unit-name
${locator.items.quantity}                                      item-quantity
${locator.items.description}                                   item-description
${locator.items.deliveryAddress.countryName_en}                country_en
${locator.questions[0].title}                                  css=.question-title
${locator.questions[0].description}                            css=.question-description
${locator.questions[0].date}                                   css=.question-date
${locator.questions[0].answer}                                 css=.question-answer

${locator.status}                                              id=currentStatus
${locator.auction_link}                                        css=.tender-auction-link

${locator.document.title}                                      css=.tender-document-title

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=      prepare_test_data  ${tender_data}
  ${lotsExist}=        Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data}  lots
  Set Global Variable  ${lotsExist}   ${lotsExist}
  [return]             ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  Open Browser         ${BROKERS['${broker}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size      @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If       '${username}' != 'ubiz_Viewer'  Login  ${username}
  Set Global Variable  ${TENDER_VIEW_URL}  ${EMPTY}

Login
  [Arguments]  ${username}
  Wait Until Page Contains Element  id=login-button  30
  Click Element                     id=login-button
  Sleep                             1
  Wait Until Page Contains Element  id=login-form-login    30
  Input text                        xpath=//input[contains(@id, 'login-form-login')]     ${USERS.users['${username}'].login}
  Input text                        xpath=//input[contains(@id, 'login-form-password')]  ${USERS.users['${username}'].password}
  Click Element                     id=login-form-button
  Wait Until Page Contains Element  css=.logout  30
  Go To                             ${USERS.users['${username}'].homepage}

Set period belowThreshold
  [Arguments]  ${tender_data}
  ${enquiry_end_date}=  Get From Dictionary   ${tender_data.data.enquiryPeriod}  endDate
  ${enquiry_end_date}=  convert_datetime_for_input   ${enquiry_end_date}
  Execute Javascript    $('#${procurementMethodTypeLower}-enquiryperiod-enddate').val('${enquiry_end_date}');
  ${start_date}=        Get From Dictionary   ${tender_data.data.tenderPeriod}  startDate
  ${start_date}=        convert_datetime_for_input   ${start_date}
  ${end_date}=          Get From Dictionary   ${tender_data.data.tenderPeriod}  endDate
  ${end_date}=          convert_datetime_for_input   ${end_date}
  Execute Javascript    $('#${procurementMethodTypeLower}-tenderperiod-startdate').val('${start_date}');
  Execute Javascript    $('#${procurementMethodTypeLower}-tenderperiod-enddate').val('${end_date}');

Set period aboveThreshold
  [Arguments]  ${tender_data}
  ${end_date}=  Get From Dictionary   ${tender_data.data.tenderPeriod}   endDate
  ${end_date}=  convert_datetime_for_input   ${end_date}
  Execute JavaScript  $('#${procurementMethodTypeLower}-tenderperiod-enddate').val('${end_date}');

Set classification
  [Arguments]  ${classificationId}   ${code}   ${scheme}
  Return From Keyword If  '${scheme}' == 'ДКПП'  ${False}
  Клацнути і дочекатися         xpath=//a[contains(@class, '${classificationId}')]   xpath=//input[contains(@id, 'classificationsearch-code')]  30
  Run Keyword And Ignore Error  Select From List By Value   id=classificationsearch-scheme   ${scheme}
  Sleep                         1
  Input text                    xpath=//input[contains(@id, 'classificationsearch-code')]           ${code}
  Click Element                 xpath=//*[contains(@id, 'classification-search-find')]
  Wait Until Page Contains Element  xpath=//tr[contains(@data-classification, '${code}')]     5
  Sleep                         1
  Click Element                 xpath=//tr[contains(@data-classification, '${code}')]
  Sleep                         2
  Click Element                 id=save-and-hide-modal-btn
  Sleep                         3

Англ поля тендера
  [Arguments]  ${tender_data}
  ${titleEn}=        Get From Dictionary  ${tender_data.data}  title_en
  ${descriptionEn}=  Get From Dictionary  ${tender_data.data}  description_en
  Run Keyword And Ignore Error  Input Text  xpath=//input[contains(@id, 'titleen')]  ${titleEn}
  Run Keyword And Ignore Error  Input Text  xpath=//textarea[contains(@id, 'descriptionen')]  ${descriptionEn}

Створити тендер
  [Arguments]   ${username}   ${tender_data}
  ${procurementTypeExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data}  procurementMethodType
  ${procurementMethodType}=  Run Keyword If  ${procurementTypeExist} == True   Get From Dictionary  ${tender_data.data}  procurementMethodType
  ...  ELSE  Convert To String    belowThreshold
  ${procurementMethodType}=  convert_ubiz_string_to_common_string    ${procurementMethodType}
  Set Global Variable  ${procurementMethodType}
  ${procurementMethodTypeLower}=   string_lower    ${procurementMethodType}
  Set Global Variable  ${procurementMethodTypeLower}
  ${procurementMethodTypeStudly}=   string_studly    ${procurementMethodType}
  Set Global Variable  ${procurementMethodTypeStudly}
  ${title}=               Get From Dictionary   ${tender_data.data}               title
  ${description}=         Get From Dictionary   ${tender_data.data}               description
  ${budget}=              Get From Dictionary   ${tender_data.data.value}         amount
  ${minimalStepExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data}  minimalStep
  ${minimalStep}=  Run Keyword If  ${minimalStepExist} == True   Get From Dictionary  ${tender_data.data.minimalStep}   amount
  ...  ELSE  Convert To String    ''
  Selenium2Library.Switch Browser    ${username}
  Wait Until Page Contains Element   id=add_tender    0
  ${controller}=   convert_method_type_to_controller   ${procurementMethodType}
  Клацнути і дочекатися  id=add_tender   xpath=//a[contains(@href, '${controller}/create')]  0
  Click Element   xpath=//a[contains(@href, '${controller}/create')]
  Run Keyword IF  ${lotsExist} == True   Execute Javascript  setMySwitchBox('${procurementMethodTypeLower}-multilots', '${lotsExist}')
  Wait Until Page Contains          ТОВ 4k-soft
  Wait Until Page Contains Element   xpath=//input[contains(@id, '${procurementMethodTypeLower}-title')]
  Input text    xpath=//input[contains(@id, '${procurementMethodTypeLower}-title')]                  ${title}
  Input text    xpath=//textarea[contains(@id, '${procurementMethodTypeLower}-description')]           ${description}
  ${title_enExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data}  title_en
  Run Keyword If  ${title_enExist}  Англ поля тендера  ${tender_data}
  # ${title_en}=  Run Keyword If  ${title_enExist} == True   Get From Dictionary  ${tender_data.data}  title_en
  # Run Keyword IF  '${procurementMethodType}' == 'aboveThresholdEu'   Input Text  xpath=//input[contains(@id, '${procurementMethodTypeLower}-titleen')]  ${title_en}

  ${causeExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data}  cause
  ${cause}=  Run Keyword If  ${causeExist} == True   Get From Dictionary  ${tender_data.data}  cause
  ${cause}=  convert_ubiz_string_to_common_string    ${cause}
  Run Keyword IF  ${causeExist} == True   Execute Javascript  setMySelectBox("${procurementMethodTypeLower}-cause", "${cause}")

  ${causeDescriptionExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data}  causeDescription
  ${causeDescription}=  Run Keyword If  ${causeDescriptionExist} == True   Get From Dictionary  ${tender_data.data}  causeDescription
  Run Keyword IF  ${causeDescriptionExist} == True   Input Text  xpath=//*[contains(@id, '${procurementMethodTypeLower}-causedescription')]  ${causeDescription}
  ${budget}=    Convert To String    ${budget}
  ${minimalStep}=    Convert To String    ${minimalStep}
  Run Keyword If  ${lotsExist} == False   Input text    xpath=//input[contains(@id, '${procurementMethodTypeStudly}-value-amount')]                  ${budget}
  ${minimalStepInput}=  Run Keyword And Return Status  Element Should Be Visible    xpath=//input[contains(@id, 'minimalStep-amount')]
  Run Keyword If  ${minimalStepInput}  Input Text  xpath=//input[contains(@id, 'minimalStep-amount')]  ${minimalStep}
  ${valueAddedTaxIncluded}=   Get From Dictionary   ${tender_data.data.value}   valueAddedTaxIncluded
  Execute Javascript  setMySwitchBox('${procurementMethodTypeStudly}-value-valueAddedTaxIncluded', '${valueAddedTaxIncluded}')

  Run Keyword IF
   ...  '${procurementMethodType}' == 'belowThreshold'  Set period belowThreshold  ${tender_data}
   ...  ELSE IF  '${procurementMethodType}' == 'aboveThresholdEu' or '${procurementMethodType}' == 'aboveThresholdUa'  Set period aboveThreshold  ${tender_data}

  ${availableLanguageExist }=  Run Keyword And Return Status   Dictionary Should Contain Key  ${tender_data.data.procuringEntity.contactPoint}  availableLanguage
  ${availableLanguage}=  Run Keyword If  ${availableLanguageExist}   Get From Dictionary  ${tender_data.data.procuringEntity.contactPoint}  availableLanguage
  ${name_en}=  Run Keyword If  ${availableLanguageExist}   Get From Dictionary  ${tender_data.data.procuringEntity.contactPoint}  name_en

  Run Keyword IF  '${procurementMethodType}' == 'aboveThresholdEu'   Execute Javascript  setMySelectBox("contactPoint-language", "${availableLanguage}")
  Run Keyword IF  '${procurementMethodType}' == 'aboveThresholdEu'   Input text    xpath=//input[contains(@id, 'contactPoint-nameEn')]   ${name_en}

  ${withContactPoint}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${tender_data.data.procuringEntity}  contactPoint
  Run keyword If  ${withContactPoint}  Додати контракту особу до тендера  ${tender_data.data.procuringEntity.contactPoint}

  @{features}=   Create List
  ${featuresInList}=  Run Keyword And Return Status  List Should Contain Value  ${tender_data.data}  features
  @{features}=  Run Keyword If  ${featuresInList}  Get From Dictionary  ${tender_data.data}  features
  Run Keyword If   ${featuresInList}   Додати перший неціновий показник   ${features[1]}
  Click Element   id=next
  ${items}=               Get From Dictionary   ${tender_data.data}               items
  ${lots}=  Run Keyword If  ${lotsExist} == True   Get From Dictionary  ${tender_data.data}  lots
  Run Keyword IF
   ...  ${lotsExist} == True  Додати лоти   ${lots}   ${items}   ${features}
   ...  ELSE  Додати предмети до закупівлі   ${items}  ${features}


  Клацнути і дочекатися  id=endEdit   id=publication   10
  ${tenderId}=   Отримати інформацію про tenderId
  Click Element  id=publication
  Wait Until Keyword Succeeds   15 x   5 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   id=tenderId-${tenderId}

  Click Element  id=tenderId-${tenderId}
  Wait Until Page Contains Element     id=tenderId     5
  ${tender_UAid}=   Отримати інформацію про tenderId
  ${Ids}=   Convert To String   ${tender_UAid}
  Log  ${Ids}
  [return]  ${Ids}

Додати контракту особу до тендера
  [Arguments]   ${contactPoint}
  Input text  id=contactPoint-name   ${contactPoint.name}
  Input text  xpath=//input[contains(@id, 'contactPoint-email')]       ${contactPoint.email}
  Input text  xpath=//input[contains(@id, 'contactPoint-faxNumber')]   ${contactPoint.faxNumber}
  Input text  xpath=//input[contains(@id, 'contactPoint-telephone')]   ${contactPoint.telephone}
  Input text  xpath=//input[contains(@id, 'contactPoint-url')]         ${contactPoint.url}

Додати неціновий показник
  [Arguments]   ${feature}   ${featureIndex}
  Wait Until Element Is Visible  id=feature-features-${featureIndex}-title
  Input Text   id=feature-features-${featureIndex}-title   ${feature.title}
  Input Text   id=feature-features-${featureIndex}-description   ${feature.description}
  @{enums}=    Get From Dictionary   ${feature}   enum
  ${countEnums}=   Get Length   ${enums}
  : FOR  ${optionIndex}  IN RANGE  0  ${countEnums}
  \   Run Keyword If    ${optionIndex} > 1   Click Element   xpath=//div[contains(@class, 'field-feature-features-${featureIndex}-options')]//div[contains(@class, 'add-enum')]
  \   Input Text   id=feature-features-${featureIndex}-options-${optionIndex}-title   ${enums[${optionIndex}].title}
  \  ${enumValue}=   get_percent  ${enums[${optionIndex}].value}
  \  ${enumValue}=   Convert to String   ${enumValue}
  \   Input Text   id=feature-features-${featureIndex}-options-${optionIndex}-value   ${enumValue}

Додати перший неціновий показник
  [Arguments]   ${feature}
  Click Element   xpath=//h3[contains(.,'Нецінові показники')]
  Wait Until Page Contains   Назва показника
  Додати неціновий показник    ${feature}   0

Додати неціновий показник на предмет
  [Arguments]  ${user_name}  ${tender_id}  ${feature}  ${item_id}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Click Element   id=editTender
  Wait Until Page Contains Element   css=.edit-item
  Click Link   css=.edit-item
  Wait Until Page Contains   Нецінові показники предмету закупівлі
  Click Element   xpath=//div[contains(text(), 'Додати новий показник')]
  Wait Until Page Contains Element   id=feature-features-1-title
  Додати неціновий показник   ${feature}   1
  Click Element   id=next
  Wait Until Element Is Visible   css=.back_tend   60
  Click Link   css=.back_tend
  Wait Until Page Contains   Інформація про замовника

Додати неціновий показник на лот
  [Arguments]  ${user_name}  ${tender_id}  ${feature}  ${lot_id}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Click Element   id=editTender
  Wait Until Page Contains Element   css=.edit-lot
  Click Link   css=.edit-lot
  Wait Until Page Contains   Нецінові показники лоту
  Click Element   xpath=//div[contains(text(), 'Додати новий показник')]
  Wait Until Page Contains Element   id=feature-features-1-title
  Додати неціновий показник   ${feature}   1
  Click Element   id=next
  Wait Until Element Is Visible   css=.back_tend   60
  Click Link   css=.back_tend
  Wait Until Page Contains   Інформація про замовника

Видалити неціновий показник з предмету
  [Arguments]   ${feature_id}
  Click Link   css=.edit-item
  Wait Until Page Contains   Нецінові показники предмету закупівлі
  ${inputId}=    Get Element Attribute   xpath=//input[contains(@value, '${feature_id}')]@id
  Execute Javascript   $('#${inputId}').closest('tr').find('.js-input-remove').click();
  Sleep  2
  Click Element   id=next

Видалити неціновий показник з лоту
  [Arguments]   ${feature_id}
  Click Link   css=.edit-lot
  Wait Until Page Contains   Нецінові показники лоту
  ${inputId}=    Get Element Attribute   xpath=//input[contains(@value, '${feature_id}')]@id
  Execute Javascript   $('#${inputId}').closest('tr').find('.js-input-remove').click()
  Sleep  2
  Click Element   id=next

Видалити неціновий показник
  [Arguments]  ${user_name}  ${tender_id}  ${feature_id}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  ${of}=   ubiz.Отримати інформацію із нецінового показника   ${user_name}   ${tender_id}   ${feature_id}   featureOf
  Reload Page
  Wait Until Element Is Visible   id=editTender  30
  Click Element                   id=editTender
  Wait Until Element Is Visible   id=endEdit
  Run Keyword If   '${of}' == 'lot'    Видалити неціновий показник з лоту   ${feature_id}
  Run Keyword If   '${of}' == 'item'   Видалити неціновий показник з предмету   ${feature_id}
  Wait Until Element Is Visible        css=.back_tend   60
  Click Link                           css=.back_tend
  Wait Until Page Contains   Інформація про замовника

Клацнути і дочекатися
  [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
  [Documentation]
  ...      click_locator: Where to click
  ...      wanted_locator: What are we waiting for
  ...      timeout: Timeout
  Click Element  ${click_locator}
  Sleep    5
  Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
  Клацнути і дочекатися  id=search-main   xpath=//a[contains(@class, 'tender_name')]  10

На початок сторінки
  Execute Javascript        $(window).scrollTop(0);
  Sleep                     1
  Capture Page Screenshot

Перейти на тендер по лінку
  Go To                             ${TENDER_VIEW_URL}
  Wait Until Page Contains Element  id=publisher-info  45
  На початок сторінки

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  Selenium2Library.Switch browser   ${ARGUMENTS[0]}
  ${isSetUrl}=  Run Keyword And Return Status  Should Be Empty  ${TENDER_VIEW_URL}
  Run Keyword And Return If  ${isSetUrl} == ${False}  Перейти на тендер по лінку

  Run Keyword If    '${ARGUMENTS[0]}' == 'ubiz_Owner'   Go To   ${BROKERS['${broker}'].buy}
  ...   ELSE   Go To   ${BROKERS['${broker}'].homepage}
  ${timeout_on_wait}=             Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
  Wait Until Element Is Visible   id=main-tendersearch    ${timeout_on_wait}
  Input Text                      id=main-tendersearch    ${ARGUMENTS[1]}
  Click Element                   id=search-main
  ${found}=  Run Keyword And Return Status  Wait Until Element Is Visible  xpath=//div[contains(@class, 'one_card')]//p[contains(.,'${ARGUMENTS[1]}')]
  Capture Page Screenshot
  Run keyword If  ${found} == ${False}  Очікування тендера  ${ARGUMENTS[1]}
  Scroll Page To Element  css=.container
  Sleep                   1
  ${viewUrl}=          Get Element Attribute   xpath=//div[contains(@class, 'one_card')]//a[contains(@href, '/prozorro/tender/')]@href
  Set Global Variable  ${TENDER_VIEW_URL}  ${viewUrl}
  Перейти на тендер по лінку

Очікування тендера
  [Arguments]  ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   xpath=//div[contains(@class, 'one_card')]//p[contains(.,'${tender_uaid}')]

Завантажити документ
  [Arguments]  ${user_name}  ${file_path}  ${tenderId}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tenderId}
  Click Element                     id=editTender
  Wait Until Element Is Visible     id=editTender
  Click Element                     id=editTender
  Wait Until Page Contains Element  xpath=//h3[contains(text(), 'Документи закупівлі')]
  Прикріпити документ               Документи закупівлі    ${file_path}
  Click Element                     id=next
  Wait Until Element Is Visible     css=.back_tend   40
  Click Link                        css=.back_tend
  Wait Until Page Contains          Інформація про замовника

Прикріпити документ
  [Arguments]   ${block_title}   ${file_path}
  Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
  Click Element    xpath=//h3[contains(text(), '${block_title}')]
  Wait Until Element Is Visible   css=.add-item
  Click Element   css=.add-item
  Wait Until Element Is Visible   css=.delete-document
  Select From List By Value   xpath=//select[contains(@name, 'documentType')]  empty
  Choose File  css=.document-img  ${file_path}
  Wait Until Page Contains   Done

Завантажити документ в лот
  [Arguments]   ${user_name}   ${file_path}   ${tender_id}   ${lot_id}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Click Element              id=editTender
  Wait Until Page Contains Element   css=.edit-lot
  Click Link   css=.edit-lot
  Wait Until Page Contains   Документи лоту
  Прикріпити документ    Документи лоту    ${file_path}
  Click Element   id=next
  Wait Until Element Is Visible   css=.back_tend   40
  Click Link   css=.back_tend
  Wait Until Page Contains   Інформація про замовника

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

Пропозиція з неціновими показниками
  [Arguments]   ${parameters}
  ${countParametrs}=   Get Length   ${parameters}
  : FOR  ${index}  IN RANGE  0  ${countParametrs}
  \  ${value}=   Get From Dictionary   ${parameters[${index}]}   value
  \  ${value}=   Convert to String   ${value}
  \  ${code}=   Get From Dictionary    ${parameters[${index}]}   code
  \  Execute Javascript   $('select[data-id="${code}"]').val('${value}').change();
  \  Execute Javascript   $('.alertify-notifier').empty();

Цінова пропозиція мультилот
  [Arguments]   ${valueAmount}
  ${valueAmount}=   Convert To String    ${valueAmount}
  Input text   xpath=//input[contains(@id, 'valueLot')]   ${valueAmount}

Цінова пропозиція безлот
  [Arguments]   ${valueAmount}
  ${valueAmount}=   Convert To String    ${valueAmount}
  Input text   id=valueTender   ${valueAmount}

Пропозиція на мультилот
  [Arguments]   ${bid_data}
  ${withParametrs}=   Run Keyword And Return Status   Dictionary Should Contain Key  ${bid_data}   parameters
  Run Keyword If    ${withParametrs}    Пропозиція з неціновими показниками   ${bid_data.parameters}
  Цінова пропозиція мультилот   ${bid_data.lotValues[0].value.amount}


Подати цінову пропозицію
  [Arguments]  ${user_name}  ${tender_id}  ${bid_data}   ${lot_id}=${None}   ${features_ids}=${None}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tenderId}
  ${featureBtn}=  Run Keyword And Return Status  Element Should Be Visible  id=show-features
  Run Keyword If  ${featureBtn} and ${features_ids} == ${None}  Fail  Відстутні нецінові показники
  Click Element                   id=bidTender
  Wait Until Element Is Visible   id=bidPublication
  ${isMulty}=   Run Keyword And Return Status   Dictionary Should Contain Key  ${bid_data.data}   lotValues
  Run Keyword If   ${isMulty}   Пропозиція на мультилот   ${bid_data.data}
  ...   ELSE   Цінова пропозиція безлот   ${bid_data.data.value.amount}
  Click Element   id=bid-isqualificationcriterion
  Click Element   id=bid-nogroundsrejecting
  Видалити повідомлення
  Click Element    id=bidPublication
  Run Keyword If   ${isMulty}   Підтвердити пропозицію у модальному вікні

Перейти в кінець сторінки
  Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)

Видалити повідомлення
  Execute Javascript   $('.alertify-notifier').empty()

Підтвердити пропозицію у модальному вікні
  Wait Until Element Is Visible   id=bidPublicationMulti
  Sleep  2
  Click Element                   id=bidPublicationMulti
  Wait Until Element Is Visible   id=publisher-info   45

Показати вкладку моя пропозиція
  Wait Until Page Contains Element   xpath=//a[contains(@href,'#myBid')]
  Click Link   xpath=//a[contains(@href,'#myBid')]

Отримати статус цінової пропозиції
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Показати вкладку моя пропозиція
  ...   AND   Element Should Be Visible   css=.bid-status
  ${rawStatus}=   Get Text   css=.bid-status
  ${rawStatus}=   convert_ubiz_string_to_common_string   ${rawStatus}
  [return]   ${rawStatus}

Отримати величину цінової пропозиції
  ${rawValueAmount}=  Get Text  css=.bid-value-amount
  ${rawValueAmount}=  Evaluate  "".join("${rawValueAmount}".split(' ')).replace(",", ".")
  ${rawValueAmount}=  Convert To Number  ${rawValueAmount}
  [return]   ${rawValueAmount}

Отримати інформацію із пропозиції
  [Arguments]  ${user_name}   ${tender_id}   ${field}
  Set Global Variable   ${TENDER_VIEW_URL}  ${EMPTY}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Показати вкладку моя пропозиція
  Run Keyword And Return If    '${field}' == 'status'   Отримати статус цінової пропозиції
  Run Keyword And Return   Отримати величину цінової пропозиції

скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element    id=cancelProposition    60
  Click Element   id=cancelProposition

Активувати цінову пропозицію
  Wait Until Element Is Visible   id=bidActiveTender
  Click Link   id=bidActiveTender
  Wait Until Element Is Visible   id=publisher-info

Змінити цінову пропозицію
  [Arguments]  ${user_name}  ${tender_id}  ${field}   ${value}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Показати вкладку моя пропозиція
  Run Keyword And Return If   '${field}' == 'status'   Активувати цінову пропозицію
  Wait Until Page Contains Element    id=bidEditTender
  Click Link   id=bidEditTender
  Wait Until Page Contains Element    id=bidPublication
  Run Keyword If   ${lotsExist}   Цінова пропозиція мультилот   ${value}
  ...  ELSE   Цінова пропозиція безлот   ${value}
  Click Element   id=bid-isqualificationcriterion
  Click Element   id=bid-nogroundsrejecting
  Видалити повідомлення
  Click Element   id=bidPublication
  Run Keyword If   ${lotsExist}   Підтвердити пропозицію у модальному вікні

Змінити тип документа в пропозиції
  [Arguments]   ${locator}   ${doc_type}
  ${doc_type}=    test_doc_type_to_option_type   ${doc_type}
  Run Keyword And Ignore Error   Select From List By Value   ${locator}//select   ${doc_type}

Завантажити документ в ставку
  [Arguments]  ${user_name}   ${file_path}   ${tender_id}   ${doc_type}=${EMPTY}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Показати вкладку моя пропозиція
  Wait Until Page Contains Element    id=bidEditTender
  Click Link   id=bidEditTender
  Wait Until Page Contains    Цінова пропозиція
  Видалити повідомлення
  Перейти в кінець сторінки
  ${docBox}=    Run Keyword And Return Status    Element Should Be Visible   css=.add-item
  Run Keyword If   ${docBox} == ${FALSE}   Click Element   xpath=//h3[contains(text(), 'Документи')]
  Wait Until Element Is Visible   css=.add-item
  Click Element   css=.add-item
  Sleep    3
  ${locator}=   Set Variable   xpath=//div[@class='row form-documents-item'][last()]
  Choose File   ${locator}//input[@class='document-img']   ${file_path}
  Wait Until Page Contains   Done
  Run Keyword If    '${doc_type}' != ''   Змінити тип документа в пропозиції   ${locator}   ${doc_type}
  Click Element   id=bid-isqualificationcriterion
  Click Element   id=bid-nogroundsrejecting
  Click Element   id=bidPublication
  Run Keyword If   ${lotsExist}   Підтвердити пропозицію у модальному вікні

Змінити документ в ставці
  [Arguments]  ${user_name}  ${tender_id}  ${file_path}  ${document_id}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Показати вкладку моя пропозиція
  Wait Until Page Contains Element    id=bidEditTender
  Click Link   id=bidEditTender
  Wait Until Page Contains    Цінова пропозиція
  Видалити повідомлення
  Click Element    xpath=//h3[contains(text(), 'Документи')]
  Перейти в кінець сторінки
  Wait Until Page Contains   ${document_id}
  Choose File   css=.document-img   ${file_path}
  Wait Until Page Contains   Done
  Click Element   id=bid-isqualificationcriterion
  Click Element   id=bid-nogroundsrejecting
  Click Element   id=bidPublication
  Run Keyword If   ${lotsExist}   Підтвердити пропозицію у модальному вікні

Змінити документацію в ставці
  [Arguments]   ${user_name}   ${tender_id}   ${doc_data}   ${document_id}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Показати вкладку моя пропозиція
  Wait Until Page Contains Element    id=bidEditTender
  Click Link   id=bidEditTender
  Wait Until Page Contains    Цінова пропозиція
  Видалити повідомлення
  Перейти в кінець сторінки
  Wait Until Element Is Visible   css=.private
  Click Element   css=.private
  Wait Until Element Is Visible  xpath=//div[contains(@id, 'privateReason')]//textarea
  Input Text   xpath=//div[contains(@id, 'privateReason')]//textarea   ${doc_data.data.confidentialityRationale}
  Click Element   id=bid-isqualificationcriterion
  Click Element   id=bid-nogroundsrejecting
  Click Element   id=bidPublication
  Run Keyword If   ${lotsExist}   Підтвердити пропозицію у модальному вікні

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  Switch Browser    ${ARGUMENTS[0]}
  ${isTenderView}=  Run Keyword And Return Status  Page Should Contain Element  id=publisher-info
  Run Keyword And Return If  ${isTenderView} == ${False}  ubiz.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  На початок сторінки
  Wait Until Element Is Visible  id=reloadTender  25
  Click Element                  id=reloadTender
  Wait Until Element Is Visible  id=tenderId      25

Змінити період пропозицій
  [Arguments]   ${tenderPeriodEndDateISO}
  ${toInputFormat}=   convert_datetime_for_input   ${tenderPeriodEndDateISO}
  Execute JavaScript  $('#${procurementMethodTypeLower}-tenderperiod-enddate').val('${toInputFormat}');

Внести зміни в тендер
  [Arguments]  ${user_name}  ${tenderId}  ${parameter}  ${value}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tenderId}
  Wait Until Page Contains Element   id=editTender
  Click Element   id=editTender
  Wait Until Element Is Visible   id=editTender
  Click Element   id=editTender
  Wait Until Page Contains   Далі
  Run Keyword If  '${parameter}' == 'tenderPeriod.endDate'   Змінити період пропозицій   ${value}
  Click Element   id=next
  Wait Until Element Is Visible   css=.back_tend   40
  Click Link   css=.back_tend
  Wait Until Page Contains   Інформація про замовника

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  Wait Until Page Contains Element    ${locator.${fieldname}}    22
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Таб Протокол розкриття
  ${awardsTab}=   Run Keyword And Return Status   Element Should Be Visible   xpath=//a[contains(@href,'#awards')]
  Run Keyword If   ${awardsTab} == ${FALSE}   Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   xpath=//a[contains(@href,'#awards')]
  Click link   xpath=//a[contains(@href,'#awards')]
  Scroll To Tabs

Отримати інформацію про awards[0].documents[0].title
  Таб Протокол розкриття
  Execute Javascript   $('.fa-plus').trigger('click');
  Sleep   1
  ${title}=   Get Text   xpath=//div[contains(@class,'one_bid')]//div[@class='box-body']//a
  [return]   ${title}

Перейти до сторінки з contracts
  [Arguments]  ${username}  ${tender_uaid}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Element Is Visible   xpath=//a[contains(@href,'#contracts')]
  Click Element   xpath=//a[contains(@href,'#contracts')]
  Execute Javascript  showAllCollapsed()

Таб Контракти
  ${contractsTab}=   Run Keyword And Return Status   Element Should Be Visible   xpath=//a[contains(@href,'#contracts')]
  Run Keyword If   ${contractsTab} == ${FALSE}   Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   xpath=//a[contains(@href,'#contracts')]
  Click link   xpath=//a[contains(@href,'#contracts')]
  Scroll To Tabs

Отримати інформацію із тендера
  [Arguments]  ${user_name}  ${tender_id}  ${field_name}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Run Keyword And Return If   '${field_name}' == 'documents[0].title'   Отримати інформацію із першого документа   title
  Run Keyword And Return If   '${field_name}' == 'qualifications[0].status'   Отримати статус пропозиції кваліфікації  0
  Run Keyword And Return If   '${field_name}' == 'qualifications[1].status'   Отримати статус пропозиції кваліфікації  1
  Run Keyword And Return If   '${field_name}' == 'procuringEntity.identifier.scheme'   Return From Keyword    UA-EDR
  Run Keyword And Return If   '${field_name}' == 'awards[0].suppliers[0].name'   Отримати інформацію про назву організації з протоколу розкриття
  Run Keyword And Return If   '${field_name}' == 'awards[0].suppliers[0].identifier.legalName'   Отримати інформацію про назву організації з протоколу розкриття

  # Run Keyword And Return If   '${field_name}' == 'title_en'   Fail   Поле не відображаем
  Run Keyword And Return If   '${field_name}' == 'title_ru'   Fail   Поле не відображаем
  # Run Keyword And Return If   '${field_name}' == 'description_en'   Fail   Поле не відображаем
  Run Keyword And Return If   '${field_name}' == 'description_ru'   Fail   Поле не відображаем
  Run Keyword And Return If   '${field_name}' == 'items[0].deliveryLocation.latitude'   Fail   Поле не відображаем
  Run Keyword And Return If   '${field_name}' == 'items[0].deliveryAddress.countryName_ru'   Fail   Поле не відображаем
  Run Keyword And Return If   '${field_name}' == 'items[0].deliveryAddress.countryName_en'   Fail   Поле не відображаем
  Run Keyword And Return  Отримати інформацію про ${field_name}

Отримати інформацію про items[0].deliveryDate.startDate
  Wait Until Page Contains   Дата поставки
  ${startDate}=   Get Text   css=.delivery-start-date
  ${startDate}=   convert_date_for_delivery   ${startDate}
  [return]   ${startDate}

Отримати інформацію про items[0].deliveryDate.endDate
  Wait Until Page Contains   Дата поставки
  ${endDate}=   Get Text   css=.delivery-end-date
  ${endDate}=   convert_date_for_delivery   ${endDate}
  [return]   ${endDate}

Таб запитання та вимоги
  ${questionsComplaintsTab}=   Run Keyword And Return Status   Element Should Be Visible   xpath=//a[contains(@href,'#questions-complaints')]
  Run Keyword If   ${questionsComplaintsTab} == ${FALSE}   Wait Until Keyword Succeeds   20 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Wait Until Element Is Visible  id=publisher-info  15
  ...   AND   Scroll To Tabs
  ...   AND   Element Should Be Visible   xpath=//a[contains(@href,'#questions-complaints')]
  Scroll To Tabs
  Click link   xpath=//a[contains(@href,'#questions-complaints')]

Отримати інформацію про features[0].title
  Click Link   id=show-features
  Wait Until Page Contains   Нецінові Показники
  ${tenderFeatureTitle}=   Get Text   xpath=(//h3[contains(@class, 'features-title')])[2]
  Click Element   id=publisher-info-modal
  [return]   ${tenderFeatureTitle}

Отримати інформацію про questions[0].title
  Таб запитання та вимоги
  ${text}=   Get Text  css=.question-title
  [return]   ${text}

Отримати інформацію про awards[0].status
  Таб Протокол розкриття
  ${rawStatus}=   Get Text   css=.award-status
  ${rawStatus}=   convert_ubiz_string_to_common_string   ${rawStatus}
  [return]   ${rawStatus}

Отримати інформацію про awards[0].complaintPeriod.endDate
  Таб Протокол розкриття
  ${complaintPeriodEnd}=   Отримати текст із поля і показати на сторінці   awards.complaintPeriod.endDate
  ${complaintPeriodEnd}=   convert_date_for_compare   ${complaintPeriodEnd}
  [return]   ${complaintPeriodEnd}

Отримати інформацію про awards[0].complaintPeriod.startDate
  Таб Протокол розкриття
  ${complaintPeriodStart}=  Отримати текст із поля і показати на сторінці   awards.complaintPeriod.startDate
  ${complaintPeriodStart}=  convert_date_for_compare   ${complaintPeriodStart}
  [return]                  ${complaintPeriodStart}

Отримати інформацію про awards[0].value.amount
  Таб Протокол розкриття
  Wait Until Element Is Visible   css=.award-value
  ${amount}=                      Get Element Attribute   xpath=//p[contains(@class, 'award-value')]@data-value-amount
  ${amount}=                      Convert To Number   ${amount}
  [return]                        ${amount}

Отримати інформацію про awards[0].value.currency
  Таб Протокол розкриття
  Wait Until Element Is Visible          css=.award-value
  ${currency}=                           Get Element Attribute   xpath=//p[contains(@class, 'award-value')]@data-value-currency
  [return]                               ${currency}

Отримати інформацію про awards[0].value.valueAddedTaxIncluded
  Таб Протокол розкриття
  Wait Until Element Is Visible   css=.award-value
  ${valueaddedtaxincluded}=       Get Element Attribute   xpath=//p[contains(@class, 'award-value')]@data-value-valueaddedtaxincluded
  ${valueaddedtaxincluded}=       Convert To Boolean   ${valueaddedtaxincluded}
  [return]                        ${valueaddedtaxincluded}

Отримати інформацію про contracts[0].status
  Таб Контракти
  ${return_value}=   Отримати текст із поля і показати на сторінці   contracts.status
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про назву організації з протоколу розкриття
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.name
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.id
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   award.suppliers.identifier.id
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.scheme
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   award.suppliers.identifier.scheme
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.name
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.contactPoint.name
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.email
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.contactPoint.email
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.telephone
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.contactPoint.telephone
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.countryName
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.address.countryName
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.locality
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.address.locality
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.postalCode
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.address.postalCode
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.region
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.address.region
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.streetAddress
  Таб Протокол розкриття
  ${return_value}=   Отримати текст із поля і показати на сторінці   awards.suppliers.address.streetAddress
  [return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Отримати текст із поля і показати на сторінці   title
  [return]  ${return_value}

Отримати інформацію про title_en
  ${return_value}=   Отримати текст із поля і показати на сторінці   title_en
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${return_value}

Отримати інформацію про description_en
  ${return_value}=   Отримати текст із поля і показати на сторінці   description_en
  [return]  ${return_value}

Отримати інформацію про cause
  ${return_value}=   Отримати текст із поля і показати на сторінці   cause
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Отримати інформацію про causeDescription
  ${return_value}=   Отримати текст із поля і показати на сторінці   causeDescription
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
  ${return_value}=   Evaluate   "".join("${return_value}".split(' ')).replace(",", ".")
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".split(' ')).replace(",", ".")
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderId
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.countryName
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.address.countryName
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.locality
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.address.locality
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.postalCode
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.address.postalCode
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.region
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.address.region
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.streetAddress
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.address.streetAddress
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.name
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.contactPoint.name
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.telephone
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.contactPoint.telephone
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.url
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.contactPoint.url
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.legalName
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.identifier.legalName
  Click Element    xpath=//button[contains(@class,'close')]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.id
  Click Element    id=publisher-info
  Sleep   1
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.identifier.id
  Click Element    xpath=//button[contains(@class,'close')]
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

Отримати інформацію про qualificationPeriod.endDate
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   ${locator.qualificationPeriod.endDate}
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.endDate
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про status
  Run Keyword If  'періоду блокування' in '${TEST_NAME}'  Run Keywords
  ...   Run Keyword And Ignore Error  Click Element  id=reloadTender
  ...   AND  Wait Until Element Is Visible  id=publisher-info
  Run Keyword Unless  'періоду блокування' in '${TEST_NAME}'  Reload Page
  ${return_value}=   Отримати текст із поля і показати на сторінці   status
  ${return_value}=   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Додати лоти
  [Arguments]  ${lots}  ${items}   ${features}
  ${lots_count}=  Get Length  ${lots}
  : FOR  ${index}  IN RANGE  0  ${lots_count}
  \  Run Keyword IF  ${index} > 0  Wait Element Visibility And Click  id=add-lot
  \  Додати лот  ${lots[${index}]}   ${features}
  \  ${lot_items}=  get_items_from_lot  ${items}  ${lots[${index}].id}
  \  Додати предмети до лоту  ${lot_items}  ${lots[${index}].title}   ${features}

Додати лот
  [Arguments]   ${lot}   ${features}
  ${title}=    Get From Dictionary   ${lot}   title
  ${description}=    Get From Dictionary   ${lot}   description
  ${budget}=              Get From Dictionary   ${lot.value}         amount
  ${minimalStepExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${lot}  minimalStep
  ${minimalStep}=  Run Keyword If  ${minimalStepExist} == True   Get From Dictionary  ${lot.minimalStep}   amount
  ...  ELSE  Convert To String    ''

  Wait Until Page Contains          Узагальнена назва лоту

  Wait Until Page Contains Element   xpath=//input[contains(@id, '${procurementMethodTypeLower}lot-title')]
  Input text    xpath=//input[contains(@id, '${procurementMethodTypeLower}lot-title')]                  ${title}
  Wait Until Page Contains Element   xpath=//textarea[contains(@id, '${procurementMethodTypeLower}lot-description')]
  Input text    xpath=//textarea[contains(@id, '${procurementMethodTypeLower}lot-description')]           ${description}

  ${title_enExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${lot}  title_en
  ${title_en}=  Run Keyword If  ${title_enExist} == True   Get From Dictionary  ${lot}  title_en
  Run Keyword IF  '${procurementMethodType}' == 'aboveThresholdEu'   Input Text  xpath=//textarea[contains(@id, 'titleen')]   ${title_en}

  ${budget}=    Convert To String    ${budget}
  ${minimalStep}=    Convert To String    ${minimalStep}
  Input text    xpath=//input[contains(@id, '${procurementMethodTypeStudly}Lot-value-amount')]                  ${budget}
  Run Keyword If  ${minimalStepExist} == True   Input text    xpath=//input[contains(@id, '${procurementMethodTypeStudly}Lot-minimalStep-amount')]   ${minimalStep}
  ${lotFeatures}=   Get Length    ${features}
  Run Keyword If    ${lotFeatures} > 0   Додати перший неціновий показник   ${features[0]}
  Click Element   id=next

Числове значення
  [Arguments]  ${value}
  ${value}=  Evaluate  "".join("${value}".split(' ')).replace(",", ".")
  ${value}=  Convert To Number  ${value}
  [return]   ${value}

Отримати інформацію із лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
  Wait Until Element Is Visible   xpath=//*[contains(@class,'lot-${field_name}')]   1
  ${return_value}=   Get Text   xpath=//*[contains(@class,'lot-${field_name}')]
  Run Keyword And Return If  '${field_name}' == 'value.amount'   Числове значення   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'minimalStep.amount'   Числове значення   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'value.valueAddedTaxIncluded'   convert_ubiz_string_to_common_string   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'minimalStep.valueAddedTaxIncluded'   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Змінити value.amount лоту
  [Arguments]   ${value}
  ${value2string}=   Convert To String    ${value}
  Input Text   xpath=//input[contains(@id,'value-amount')]   ${value2string}

Змінити minimalStep.amount лоту
  [Arguments]   ${value}
  ${value2string}=   Convert To String    ${value}
  Input Text   xpath=//input[contains(@id,'minimalStep-amount')]   ${value2string}

Змінити лот
  [Arguments]  ${user_name}  ${tender_id}  ${lot_id}  ${field}  ${value}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Click Link   id=editTender
  Wait Until Page Contains Element   css=.edit-lot
  Click Link   css=.edit-lot
  Run Keyword And Return If  'value.amount' == '${field}'  Змінити ${field} лоту  ${value}
  Run Keyword And Return If  'minimalStep.amount' == '${field}'  Змінити ${field} лоту  ${value}
  Click Element   id=next
  Wait Until Element Is Visible   css=.back_tend   40
  Click Link   css=.back_tend
  Wait Until Page Contains   Інформація про замовника

Розгорнути все
  Execute Javascript   $("#lots .tab-pane").addClass("active")
  Execute Javascript   showAllCollapsed()
  Sleep                2

Додати предмет
  [Arguments]  ${item}   ${features}
  ${itemsDescription}=    Get From Dictionary   ${item}                          description
  ${description_en}=      Run Keyword If  '${procurementMethodType}' == 'aboveThresholdEu'   Get From Dictionary  ${item}  description_en
  ${quantity}=            Get From Dictionary   ${item}                          quantity
  ${unit}=                Get From Dictionary   ${item.unit}                     name
  ${unit}=                Convert To Lowercase  ${unit}
  ${cpv}=                 Get From Dictionary   ${item.classification}           id
  ${latitude}             Get From Dictionary   ${item.deliveryLocation}         latitude
  ${longitude}            Get From Dictionary   ${item.deliveryLocation}         longitude
  ${countryName}=         Get From Dictionary   ${item.deliveryAddress}     countryName
  ${region}=              Get From Dictionary   ${item.deliveryAddress}     region
  ${locality}=            Get From Dictionary   ${item.deliveryAddress}     locality
  ${postalCode}=          Get From Dictionary   ${item.deliveryAddress}       postalCode
  ${streetAddress}=       Get From Dictionary   ${item.deliveryAddress}       streetAddress

  ${deliveryDateEnd}=     Get From Dictionary   ${item.deliveryDate}          endDate
  ${deliveryDateEnd}=    convert_datetime_for_delivery   ${deliveryDateEnd}
  ${deliveryDateStart}=   Get From Dictionary   ${item.deliveryDate}          startDate
  ${deliveryDateStart}=    convert_datetime_for_delivery   ${deliveryDateStart}

  Wait Until Page Contains Element   xpath=//textarea[contains(@id, '${procurementMethodTypeLower}item-description')]
  Input text    xpath=//textarea[contains(@id, '${procurementMethodTypeLower}item-description')]     ${itemsDescription}
  Run Keyword IF  '${procurementMethodType}' == 'aboveThresholdEu'   Input text    xpath=//textarea[contains(@id, '${procurementMethodTypeLower}item-descriptionen')]   ${description_en}

  Wait Until Page Contains Element   xpath=//input[contains(@id, '${procurementMethodTypeLower}item-quantity')]
  Input text    xpath=//input[contains(@id, '${procurementMethodTypeLower}item-quantity')]           ${quantity}

  ${unit}=   Convert To String   ${unit}
  Execute Javascript  setMySelectBox("${procurementMethodTypeLower}item-unit", "${unit}")
  Sleep    1
  Set classification   classificationCpv   ${cpv}   ДК021
  ${additionalClassificationsExist}=  Run Keyword And Return Status   Dictionary Should Contain Key  ${item}   additionalClassifications
  ${addId}=    Run Keyword IF  ${additionalClassificationsExist}   Get From Dictionary   ${item.additionalClassifications[0]}   id
  ${addScheme}=    Run Keyword IF  ${additionalClassificationsExist}   Get From Dictionary   ${item.additionalClassifications[0]}   scheme
  Run Keyword IF  ${additionalClassificationsExist}   Set classification   classificationMulti   ${addId}   ${addScheme}
  Scroll Page To Element    id=deliveryAddress
  Run Keyword And Ignore Error   Execute Javascript  setMySwitchBox("${procurementMethodTypeLower}item-deliveryrequired", "true")
  Sleep    2
  Scroll Page To Element    id=deliveryAddress

  Input text    xpath=//input[contains(@id, 'deliveryAddress-locality')]           ${locality}
  Input text    xpath=//input[contains(@id, 'deliveryAddress-address')]           ${streetAddress}
  ${region}=   convert_ubiz_string_to_common_string   ${region}
  Execute Javascript  setMySelectBox("deliveryAddress-regionId", "${region}")
  Input text    xpath=//input[contains(@id, 'deliveryAddress-postalCode')]           ${postalCode}

  Execute Javascript    $('#${procurementMethodTypeLower}item-deliverydate-startdate').val('${deliveryDateStart}');
  Execute Javascript    $('#${procurementMethodTypeLower}item-deliverydate-enddate').val('${deliveryDateEnd}');

  ${itemFeatures}=   Get Length    ${features}
  Run Keyword If    ${itemFeatures} > 0   Додати перший неціновий показник   ${features[2]}

  Клацнути і дочекатися  id=next   id=endEdit   10

Wait Element Visibility And Input Text
  [Arguments]  ${elementLocator}  ${input}
  Wait Until Element Is Visible  ${elementLocator}  10
  Input Text  ${elementLocator}  ${input}

Wait Element Visibility And Click
  [Arguments]  ${elementLocator}
  Wait Until Element Is Visible  ${elementLocator}  10
  Click Element    ${elementLocator}

Додати предмети до лоту
  [Arguments]  ${items}  ${lot_title}   ${features}
  ${items_count}=  Get Length  ${items}

  : FOR  ${index}  IN RANGE  0  ${items_count}
  \  Run Keyword IF  ${index} > 0   Execute Javascript   $(".tab-pane").addClass("active")
  \  Sleep    3
  \  Run Keyword IF  ${index} > 0   Wait Element Visibility And Click  xpath=//a[contains(@data-lot-title, "${lot_title}")]
  \  Додати предмет  ${items[${index}]}   ${features}

Додати предмети до закупівлі
  [Arguments]  ${items}   ${features}
  ${items_count}=  Get Length  ${items}

  : FOR  ${index}  IN RANGE  0  ${items_count}
  \  Run Keyword IF  ${index} > 0  Wait Element Visibility And Click  id=add-item
  \  Додати предмет  ${items[${index}]}   ${features}

Відкрити блок предмету
  [Arguments]  ${item_id}
  Wait Until Element Is Visible  xpath=//div[@id='lots']//a[contains(text(),'${item_id}')]
  Click Element                  xpath=//div[@id='lots']//a[contains(text(),'${item_id}')]
  Wait Until Element Is Visible  xpath=//div[contains(@data-item-description,'${item_id}')]

Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Scroll To Tabs
  Run Keyword IF  ${lotsExist}  Розгорнути все
  Run Keyword If  ${lotsExist} == ${False}  Відкрити блок предмету  ${item_id}
  ${class}=  Run Keyword If  '${field_name}' == 'unit.code'   Catenate  SEPARATOR=  items.  unit.name
  ...  ELSE  Catenate  SEPARATOR=  items.  ${fieldname}
  Wait Until Element Is Visible  xpath=//div[contains(@data-item-description,'${item_id}')]//*[contains(@class,'${locator.${class}}')]

  ${return_value}=  Run Keyword If  '${field_name}' == 'deliveryDate.startDate' or '${field_name}' == 'deliveryDate.endDate'  Get Element Attribute  xpath=//div[contains(@data-item-description,'${item_id}')]//*[contains(@class,'${locator.${class}}')]@data-value
  ...  ELSE  Get Text  xpath=//div[contains(@data-item-description,'${item_id}')]//*[contains(@class,'${locator.${class}}')]
  Run Keyword And Return If  '${field_name}' == 'classification.scheme'    convert_ubiz_string_to_common_string   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'unit.code'                convert_ubiz_string_to_common_string   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'deliveryAddress.region'   convert_ubiz_string_to_common_string   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'additionalClassifications[0].scheme'   convert_ubiz_string_to_common_string   ${return_value}
  Run Keyword And Return If  '${field_name}' == 'quantity'   Convert To Number   ${return_value}

  [return]  ${return_value}

Задати запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question}  ${related_id}
  ${title}=        Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element   xpath=//a[contains(@id,'questionTender')]
  Click Element    xpath=//a[contains(@id,'questionTender')]
  Wait Until Page Contains Element   id=question-title
  Input text                         id=question-title                 ${title}
  Input text                         id=question-description           ${description}
  Click Element                      id=next

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  Задати запитання  ${username}  ${tender_uaid}  ${question}  ${tender_uaid}

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  Задати запитання  ${username}  ${tender_uaid}  ${question}  ${item_id}

Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}
  Задати запитання  ${username}  ${tender_uaid}  ${question}  ${lot_id}

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  ${answer}=     Get From Dictionary  ${answer_data.data}  answer
  ubiz.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Таб запитання та вимоги
  Wait Until Page Contains Element   xpath=//a[contains(@href,'#qc-questions')]
  Click Element    xpath=//a[contains(@href,'#qc-questions')]
  Wait Until Page Contains   ${question_id}
  Click Element    xpath=//div[contains(@data-question-title,'${question_id}')]//a[contains(@id,'answerQuestionTender')]
  Wait Until Page Contains   Відповідь на задане питання
  Input text    id=questionanswer-answer   ${answer}
  Click Element   id=next
  Wait Until Page Contains   Інформація про замовника

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Таб запитання та вимоги
  Wait Until Element Is Visible   xpath=//a[contains(@href,'#qc-questions')]
  Click Element    xpath=//a[contains(@href,'#qc-questions')]
  Wait Until Element Is Visible   ${locator.questions[0].${field_name}}
  ${return_value}=   Get Text   ${locator.questions[0].${field_name}}
  [return]  ${return_value}

Рішення щодо вимоги
  [Arguments]  ${complaintID}
  ${satisfied}=  Get Element Attribute   xpath=//div[@data-complaintid='${complaintID}']//*[@data-field='status']@data-value
  ${satisfied}=  convert_ubiz_string_to_common_string  ${satisfied}
  [return]       ${satisfied}

Скарги до початку кваліфікації переможця
  Click Element                      xpath=//a[@href='#questions-complaints']
  Wait Until Page Contains Element   xpath=//a[@href='#qc-claims']
  Click Element                      xpath=//a[@href='#qc-claims']

Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If  '${field_name}' == 'status'  Run Keyword And Ignore Error  ubiz.Оновити сторінку з тендером  ${username}  ${tender_uaid}
  Scroll To Tabs
  ${isAwardComplaint}=  Run Keyword And Return Status  Element Should Be Visible  xpath=//a[@href='#awards']
  Run Keyword If  ${isAwardComplaint}  Click Element   xpath=//a[@href='#awards']
  ...   ELSE                           Скарги до початку кваліфікації переможця
  Wait Until Page Contains Element   xpath=//div[@data-complaintid='${complaintID}']
  Run Keyword And Return If  '${field_name}' == 'satisfied'       Рішення щодо вимоги  ${complaintID}
  Run Keyword And Return If  '${field_name}' == 'status'          Get Element Attribute   xpath=//div[@data-complaintid='${complaintID}']//span[@data-field='status']@data-value
  Run Keyword And Return If  '${field_name}' == 'resolutionType'  Get Element Attribute   xpath=//div[@data-complaintid='${complaintID}']//*[@data-field='resolutionType']@data-value
  Run Keyword And Return If  '${field_name}' == 'resolution'      Get Text  xpath=//div[@data-complaintid='${complaintID}']//*[@class='complaints-${field_name}']
  ${fieldValue}=                                                  Get Text  xpath=//div[@data-complaintid='${complaintID}']//*[contains(@class,'complaints-${field_name}')]
  [return]                                                        ${fieldValue}

Отримати посилання на аукціон для глядача
  [Arguments]  ${user_name}  ${tender_id}  ${lot_id}=${EMPTY}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Очікування посилання
  Run Keyword And Return    Get Element Attribute   id=auctionTender@href

Очікування посилання
  Wait Until Keyword Succeeds   50 x   45 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   id=auctionTender  15

Отримати посилання на аукціон по лоту в модальному вікні
  [Arguments]   ${lot_id}
  Click Link                id=auctionTender
  Wait Until Page Contains  Перегляд аукціонів по лотам
  Run Keyword And Return    Get Element Attribute   xpath=//a[contains(text(), '${lot_id}')]@href

Отримати посилання на аукціон для учасника
  [Arguments]  ${user_name}  ${tender_id}  ${lot_id}=${None}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Очікування посилання
  ${url}=   Get Element Attribute   id=auctionTender@href
  Run Keyword And Return If   '${url}' == '#'   Отримати посилання на аукціон по лоту в модальному вікні   ${lot_id}
  [return]   ${url}

Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field_name}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   xpath=//a[contains(@href,'#documents')]
  ...   AND   Click Link   xpath=//a[contains(@href,'#documents')]
  Scroll Page To Element   xpath=//a[contains(@href,'#documents')]
  Execute Javascript   $("#documents .tab-pane").addClass("active")
  Wait Until Page Contains Element   xpath=//a[contains(., '${doc_id}')]
  ${return_value}=   Get Text   xpath=//a[contains(., '${doc_id}')]
  [return]   ${return_value}

Scroll Page To Element
  [Arguments]  ${locator}
  ${temp}=  Remove String  ${locator}  '
  ${cssLocator}=  Run Keyword If  'css' in '${temp}'  Get Substring  ${locator}  4
  ...  ELSE  Get Substring  ${locator}  6
  ${js_expresion}=  Run Keyword If  'css' in '${temp}'  Convert To String  return window.$("${cssLocator}")[0].scrollIntoView()
  ...  ELSE  Convert To String  return window.$x("${cssLocator}")[0].scrollIntoView()
  Sleep  2s

Отримати інформацію із документа до скасування
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_id}  ${doc_id}  ${field_name}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element    xpath=//a[contains(@href,'#documents')]
  Execute Javascript   $("#documents .tab-pane").addClass("active")
  Wait Until Page Contains Element   xpath=//div[contains(@class,'row') and contains(@data-doc-title,'${doc_id}')]//*[contains(@class,'doc-${field_name}')]
  ${return_value}=   Get Text   xpath=//div[contains(@class,'row') and contains(@data-doc-title,'${doc_id}')]//*[contains(@class,'doc-${field_name}')]
  [return]  ${return_value}

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   xpath=//a[contains(@href,'#documents')]
  ...   AND   Click Element    xpath=//a[contains(@href,'#documents')]
  ...   AND   Element Should Be Visible    xpath=//a[contains(text(), '${doc_id}')]
  ${file_name}=   Get Text   xpath=//a[contains(text(), '${doc_id}')]
  ${url}=   Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@href
  download_document_from_url   ${url}   ${file_name}   ${OUTPUT_DIR}
  [return]  ${file_name}

Очікування документів
  Wait Until Keyword Succeeds   10 x   20 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   xpath=//a[contains(@href,'#documents')]
  ...   AND   Click Element    xpath=//a[contains(@href,'#documents')]

Отримати інформацію із першого документа
  [Arguments]   ${field_name}
  Очікування документів
  Run Keyword And Return   Get Text   xpath=//div[@id='doc-all']//a

Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
  ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Element Is Visible   xpath=//a[contains(@href,'#documents')]
  Click Link    xpath=//a[contains(@href,'#documents')]
  Execute Javascript   $("#documents .tab-pane").addClass("active")
  Wait Until Page Contains Element   xpath=//a[contains(text(), '${doc_id}')]
  ${file_name}=   Get Text   xpath=//a[contains(text(), '${doc_id}')]
  ${url}=   Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@href
  download_document_from_url   ${url}   ${file_name}   ${OUTPUT_DIR}
  [return]  ${file_name}

Отримати інформацію із нецінового показника
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
  На початок сторінки
  Wait Until Page Contains Element   xpath=//*[contains(@id,'show-features')]
  Click Element    xpath=//*[contains(@id,'show-features')]
  Execute Javascript  showAllCollapsed()
  Wait Until Element Is Visible   xpath=//div[contains(@class,'features-parent') and contains(.,'${feature_id}')]//*[contains(@class, 'features-${field_name}')]   5
  ${return_value}=   Get Text  xpath=//div[contains(@class,'features-parent') and contains(.,'${feature_id}')]//*[contains(@class, 'features-${field_name}')]
  Execute Javascript  hideModal('non-price-criterion-modal')
  Run Keyword And Return If  '${field_name}' == 'featureOf'   convert_ubiz_string_to_common_string   ${return_value}
  [return]  ${return_value}

Перейти в прекваліфікаію
  [Arguments]   ${user_name}   ${tender_id}
  Set Global Variable  ${TENDER_VIEW_URL}  ${EMPTY}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tender_id}
  Wait Until Element Is Visible         id=preQualificationTender
  Click Link                            id=preQualificationTender
  Wait Until Element Is Visible         css=.back_tend
  Scroll Page To Element                css=.action_period
  Sleep                                 3
  Execute Javascript                    $('.fa-plus').trigger('click');
  Sleep                                 1

Завантажити документ у кваліфікацію
  [Arguments]   ${user_name}   ${file_path}  ${tender_id}   ${bid_index}
  Перейти в прекваліфікаію   ${user_name}   ${tender_id}
  Wait Until Element Is Visible     xpath=//div[contains(@class,'bid-0')]//a[contains(@href, '#active-')]
  Click Element                     xpath=//div[contains(@class,'bid-0')]//a[contains(@href, '#active-')]
  Wait Until Page Contains Element  xpath=//div[contains(@class,'bid-0')]//input[@class="document-img"]
  Choose File                       xpath=//div[contains(@class,'bid-0')]//input[@class="document-img"]   ${file_path}
  Wait Until Page Contains          Done
  Click Element                     xpath=//div[contains(@class,'bid-0')]//input[contains(@id, 'pre-qualification-qualified')]
  Click Element                     xpath=//div[contains(@class,'bid-0')]//input[contains(@id, 'pre-qualification-eligible')]
  Click Element                     xpath=//div[contains(@class,'bid-0')]//button[@name='PreQualification[status]']
  Wait Until Page Contains          Підписати ЕЦП
  Накласти ЄЦП

Підтвердити кваліфікацію
  [Arguments]  ${user_name}  ${tender_id}  ${bid_index}
  Перейти в прекваліфікаію   ${user_name}   ${tender_id}
  Wait Until Page Contains Element  xpath=//div[contains(@class,'bid-0')]//button[@name='Qualification[status]']
  Click Element                     xpath=//div[contains(@class,'bid-0')]//button[@name='Qualification[status]']

Затвердити остаточне рішення кваліфікації
  [Arguments]   ${user_name}    ${tender_id}
  Перейти в прекваліфікаію   ${user_name}   ${tender_id}
  Wait Until Element Is Visible  id=standStillPreQualification
  Click Link                     id=standStillPreQualification

Отримати статус пропозиції кваліфікації
  [Arguments]   ${index}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   id=preQualificationTender
  Click Link   id=preQualificationTender
  Wait Until Page Contains   Прекваліфікація
  ${status}=   Get Text   xpath=//div[contains(@class,'bid-${index}')]//span[contains(@class,'bid-status')]
  ${status}=   convert_ubiz_string_to_common_string   ${status}
  [return]   ${status}

Накласти ЄЦП
  Клацнути і дочекатися    xpath=//a[contains(@href,"/ecp/")]    id=CAsServersSelect   60
  Sleep    3
  ${status}=  Run Keyword And Return Status  Page Should Contain  Оберіть файл з особистим ключем (зазвичай з ім'ям Key-6.dat) та вкажіть пароль захисту
  Run Keyword If  ${status}  Run Keywords
  ...  Select From List By Label  id=CAsServersSelect  Тестовий ЦСК АТ "ІІТ"
  ...  AND  Execute Javascript  var element = document.getElementById('PKeyFileInput'); element.style.visibility="visible";
  ...  AND  Choose File     id=PKeyFileInput   ${CURDIR}/Key-6.dat
  ...  AND  Input text      id=PKeyPassword   12345677
  ...  AND  Click Element   id=PKeyReadButton
  ...  AND  Wait Until Page Contains   Ключ успішно завантажено   75
  Click Element              id=SignDataButton
  Wait Until Page Contains   Підпис успішно накладено   60
  Execute Javascript   hideModal('inform_window')

Scroll To Tabs
  Execute Javascript   var targetOffset = $('.nav-tabs-ubiz').offset().top; $('html, body').animate({scrollTop: targetOffset}, 1000);
  Sleep   1

Створити постачальника, додати документацію і підтвердити його
  [Arguments]   ${user_name}   ${tender_id}   ${supplier_data}   ${file}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Wait Until Element Is Visible     id=addAwardTender   15
  Click Element                     id=addAwardTender
  Wait Until Element Is Visible     id=supplier-name   15
  Input Text                        id=supplier-name            ${supplier_data.data.suppliers[0].name}
  ${valueAmount}                    Get From Dictionary         ${supplier_data.data.value}   amount
  ${valueAmount}                    Convert To String           ${valueAmount}
  Input Text                        id=Supplier-value-amount    ${valueAmount}
  Input Text                        id=supplier-legal_name      ${supplier_data.data.suppliers[0].identifier.legalName}
  Input Text                        id=supplier-edrpou          ${supplier_data.data.suppliers[0].identifier.id}
  Input text                        id=contactPoint-name        ${supplier_data.data.suppliers[0].contactPoint.name}
  Input text                        id=contactPoint-email       ${supplier_data.data.suppliers[0].contactPoint.email}
  Input text                        id=contactPoint-faxNumber   ${supplier_data.data.suppliers[0].contactPoint.faxNumber}
  Input text                        id=contactPoint-telephone   ${supplier_data.data.suppliers[0].contactPoint.telephone}
  Input text                        id=contactPoint-url         ${supplier_data.data.suppliers[0].contactPoint.url}
  ${region}=                        Get From Dictionary         ${supplier_data.data.suppliers[0].address}     region
  ${region}=                        convert_ubiz_string_to_common_string   ${region}
  Execute Javascript                setMySelectBox("addressFirm-regionId", "${region}")
  Input Text                        id=addressFirm-locality         ${supplier_data.data.suppliers[0].address.locality}
  Input Text                        id=addressFirm-address          ${supplier_data.data.suppliers[0].address.streetAddress}
  Input text                        id=addressFirm-postalCode       ${supplier_data.data.suppliers[0].address.postalCode}
  #Click Element                     xpath=//div[@id='supplier-qualified']//input
  Click Element                     id=next
  Wait Until Page Contains Element  xpath=//p[contains(text(), 'Кваліфікація')]
  Sleep                             2
  Execute Javascript                $('.fa-plus').trigger('click');
  Sleep                             1
  Scroll Page To Element            css=.box-body
  Click Element                     xpath=//a[contains(text(), 'Допустити')]

  Wait Until Element Is Visible     css=.add-item
  Click Element                     css=.add-item
  Wait Until Element Is Visible     css=.delete-document
  Choose File                       css=.document-img  ${file}
  Wait Until Page Contains          Done
  ${qualificationCheckBoxes}=       Run Keyword And Return Status  Element Should Be Visible  xpath=//input[contains(@id, 'qualification-qualified')]
  Run Keyword If                    ${qualificationCheckBoxes}  Чекбокси кваліфікації
  Click Element                     xpath=//button[@name='Qualification[status]']
  Wait Until Page Contains          Розглядається   30
  Sleep    1
  Накласти ЄЦП
  Wait Until Page Contains Element   xpath=//button[@name='Qualification[status]']
  Scroll Page To Element             css=.action_period
  Sleep                              1
  Click Element                      xpath=//button[@name='Qualification[status]']
  Wait Until Page Contains           Пропозицію прийнято   40
  Click Link                         css=.back_tend

Чекбокси кваліфікації
  Click Element  xpath=//input[contains(@id, 'qualification-qualified')]
  Click Element  xpath=//input[contains(@id, 'qualification-eligible')]

Отримати інформацію із документа до скарги
  [Arguments]  ${user_name}   ${tender_uaid}   ${complaint_id}  ${doc_id}  ${field}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tender_uaid}
  Scroll To Tabs
  ${isAwardComplaint}=  Run Keyword And Return Status  Element Should Be Visible  xpath=//a[@href='#awards']
  Run Keyword If  ${isAwardComplaint}  Click Element   xpath=//a[@href='#awards']
  ...   ELSE                           Скарги до початку кваліфікації переможця
  Wait Until Page Contains Element     xpath=//div[@data-complaintid='${complaint_id}']//a[contains(@href, 'openprocurement')]
  ${doc_text}=              Get Text   xpath=//div[@data-complaintid='${complaint_id}']//a[contains(@href, 'openprocurement')]
  [return]                             ${doc_text}

Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaintID}  ${answer_data}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Scroll To Tabs
  ...   AND   Wait Until Element Is Visible   xpath=//a[contains(@href,'#questions-complaints')]
  ...   AND   Click Element                   xpath=//a[contains(@href,'#questions-complaints')]
  ...   AND   Wait Until Element Is Visible   xpath=//a[contains(@href,'#qc-claims')]
  ...   AND   Click Element                   xpath=//a[contains(@href,'#qc-claims')]
  ...   AND   Wait Until Element Is Visible   xpath=//div[@data-complaintid='${complaintID}']

  Click Link                                  xpath=//div[@data-complaintid='${complaintID}']//a[contains(@href, '/prozorro/complaint/answer')]
  Відповісти на скаргу                        ${answer_data.data}

Відповісти на скаргу
  [Arguments]   ${answer_data}
  Wait Until Page Contains Element    id=complaintanswer-resolution   15
  ${resolutionType}=                  Get From Dictionary   ${answer_data}   resolutionType
  ${resolutionType}=                  convert_ubiz_string_to_common_string   resolution_${resolutionType}
  Execute Javascript                  setMySelectBox("complaintanswer-resolutiontype", "${resolutionType}")
  Input Text                          id=complaintanswer-resolution       ${answer_data.resolution}
  Input Text                          id=complaintanswer-tendereraction   ${answer_data.tendererAction}
  Capture Page Screenshot
  Click Element                       id=next

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${user_name}  ${file}  ${tender_uaid}  ${award_num}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Wait Until Element Is Visible   id=qualificationTender
  ...   AND   Click Element                   id=qualificationTender
  Wait Until Element Is Visible      xpath=//a[contains(text(), 'Допустити')]
  Click Element                      xpath=//a[contains(text(), 'Допустити')]
  Wait Until Element Is Visible      css=.add-item
  Click Element                      css=.add-item
  Wait Until Element Is Visible      css=.delete-document
  Choose File                        css=.document-img  ${file}
  Wait Until Page Contains           Done
  Click Element                      xpath=//button[@name='Qualification[status]']
  Wait Until Page Contains           Розглядається
  Накласти ЄЦП
  Wait Until Page Contains Element   xpath=//button[@name='Qualification[status]']  30
  ubiz.Підтвердити постачальника  ${user_name}  ${tender_uaid}  ${award_num}

Підтвердити постачальника
  [Arguments]  ${user_name}  ${tender_id}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  ${qualificationBtn}=  Run Keyword And Return Status  Element Should Be Visible  id=qualificationTender
  Run Keyword If  ${qualificationBtn}   Run Keywords
  ...   Click Element  id=qualificationTender
  ...   AND   Wait Until Page Contains Element  xpath=//button[@name='Qualification[status]']
  ...   AND   Click Element                     xpath=//button[@name='Qualification[status]']
  ...   AND   Wait Until Page Contains          Пропозицію прийнято  40

Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Scroll To Tabs
  ...   AND   Wait Until Element Is Visible   xpath=//a[contains(@href,'#awards')]
  ...   AND   Click Element                   xpath=//a[contains(@href,'#awards')]
  ...   AND   Wait Until Element Is Visible   xpath=//div[@data-complaintid='${complaintID}']
  Scroll To Tabs
  Click Link                                  xpath=//div[@data-complaintid='${complaintID}']//a[contains(@href, '/prozorro/award-complaint/answer')]
  Відповісти на скаргу                        ${answer_data.data}

Підтвердити підписання контракту
  [Arguments]  ${user_name}  ${tender_uaid}  ${contract_num}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}   ${tender_uaid}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Scroll To Tabs
  ...   AND   Wait Until Element Is Visible   xpath=//a[contains(@href,'#contracts')]
  ...   AND   Click Element                   xpath=//a[contains(@href,'#contracts')]
  ...   AND   Wait Until Element Is Visible   xpath=//a[contains(@href,'/prozorro/contract/awarded')]
  ...   AND   Click Element                   xpath=//a[contains(@href,'/prozorro/contract/awarded')]
  Wait Until Element Is Visible               id=contract-contractnumber

  ${getProcediureType}=                       Get Text  xpath=//span[@class='text-muted dib']
  ${isNegotiation}=       Run Keyword And Return Status  Should Be Equal  ${getProcediureType}  Переговорна процедура

  Scroll Page To Element                      css=.action_period
  Sleep                                       1
  Input Text                                  id=contract-contractnumber    ${tender_uaid}
  ${currentDate}=                             get_contract_end_date
  Execute Javascript                          $('#contract-period-enddate').val('${currentDate}');
  Execute Javascript                          $('#contract-period-enddate-disp').val('${currentDate}');

  Run Keyword And Return If  ${isNegotiation}  Підтвердити контракт для переговорної
  Click Element                                xpath=//button[@data-status='4']
  Wait Until Element Is Visible                xpath=//a[@data-status='10']
  Sleep    1
  Накласти ЄЦП
  Wait Until Element Is Visible                css=.action_period
  Scroll Page To Element                       css=.action_period
  Wait Until Element Is Visible                xpath=//button[@data-status='3']    30
  Sleep                                        1
  Click Element                                xpath=//button[@data-status='3']

Підтвердити контракт для переговорної
  Click Element                   xpath=//button[@data-status='1']
  Wait Until Element Is Visible   xpath=//a[@data-status='10']  45
  Накласти ЄЦП
  Wait Until Element Is Visible   css=.action_period
  Scroll Page To Element          css=.action_period
  Wait Until Element Is Visible   xpath=//button[@data-status='3']    30
  Sleep                           1
  Click Element                   xpath=//button[@data-status='3']

Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_data}  ${file}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Wait Until Element Is Visible   id=draftComplaintTender
  Click Element                   id=draftComplaintTender
  Wait Until Element Is Visible   css=.action_period
  Scroll Page To Element          css=.action_period
  Input Text                      id=complaintdraft-title  ${complaint_data.data.title}
  Input Text                      id=complaintdraft-description  ${complaint_data.data.description}
  Execute Javascript              $('.fa-plus').trigger('click');
  Wait Until Element Is Visible   css=.add-item
  Click Element                   css=.add-item
  Wait Until Element Is Visible   css=.delete-document
  Choose File                     css=.document-img  ${file}
  Wait Until Page Contains        Done
  Click Element                   xpath=//button[contains(text(), 'Подати')]
  Wait Until Element Is Visible   id=publisher-info  45
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#questions-complaints']
  Wait Until Page Contains        ${complaint_data.data.title}
  ${complaintId}=                 Get Element Attribute  xpath=//div[@id='qc-claims']/div[last()]@data-complaintid
  [return]                        ${complaintId}

Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${complaint_data}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#questions-complaints']
  Wait Until Element Is Visible   xpath=//a[@href='#qc-claims']
  Click Element                   xpath=//a[@href='#qc-claims']
  Wait Until Element Is Visible   xpath=//div[@data-complaintid='${complaint_uaid}']
  Click Element                   xpath=//div[@data-complaintid='${complaint_uaid}']//a[contains(text(), 'Задоволення вимоги')]
  Wait Until Page Contains        Задоволення вимоги  45
  Scroll Page To Element          css=.action_period
  Sleep                           1
  Run Keyword If  ${complaint_data.data.satisfied}  Click Element  xpath=//div[@id='complaintresolve-satisfied']//input[@value="1"]
  ...   ELSE   Click Element  xpath=//div[@id='complaintresolve-satisfied']//input[@value="0"]
  Sleep  1
  Capture Page Screenshot
  Click Element  xpath=//button[contains(text(), 'Підтвердити')]

Створити вимогу про виправлення умов лоту
  [Arguments]  ${user_name}  ${tender_id}  ${complaint_data}  ${lot_id}  ${file}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_id}
  Wait Until Element Is Visible   id=draftComplaintTender
  Click Element                   id=draftComplaintTender
  Wait Until Element Is Visible   css=.action_period
  Scroll Page To Element          css=.action_period
  Execute Javascript              $("#claim-element").val($("#claim-element :contains('${lot_id}') option").first().attr("value")).change();
  Input Text                      id=complaintdraft-title  ${complaint_data.data.title}
  Input Text                      id=complaintdraft-description  ${complaint_data.data.description}
  Execute Javascript              $('.fa-plus').trigger('click');
  Wait Until Element Is Visible   css=.add-item
  Click Element                   css=.add-item
  Wait Until Element Is Visible   css=.delete-document
  Choose File                     css=.document-img  ${file}
  Wait Until Page Contains        Done
  Click Element                   xpath=//button[contains(text(), 'Подати')]
  Wait Until Element Is Visible   id=publisher-info  45
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#questions-complaints']
  Wait Until Page Contains        ${complaint_data.data.title}
  ${complaintId}=                 Get Element Attribute  xpath=//div[@id='qc-claims']/div[last()]@data-complaintid
  [return]                        ${complaintId}

Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${complaint_data}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#questions-complaints']
  Wait Until Element Is Visible   xpath=//a[@href='#qc-claims']
  Click Element                   xpath=//a[@href='#qc-claims']
  Wait Until Element Is Visible   xpath=//div[@data-complaintid='${complaint_uaid}']
  Click Element                   xpath=//div[@data-complaintid='${complaint_uaid}']//a[contains(text(), 'Задоволення вимоги')]
  Wait Until Page Contains        Задоволення вимоги  45
  Scroll Page To Element          css=.action_period
  Sleep                           1
  Run Keyword If  ${complaint_data.data.satisfied}  Click Element  xpath=//div[@id='complaintresolve-satisfied']//input[@value="1"]
  ...   ELSE   Click Element  xpath=//div[@id='complaintresolve-satisfied']//input[@value="0"]
  Sleep  1
  Capture Page Screenshot
  Click Element  xpath=//button[contains(text(), 'Підтвердити')]

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_data}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Wait Until Element Is Visible   id=draftComplaintTender
  Click Element                   id=draftComplaintTender
  Wait Until Element Is Visible   css=.action_period
  Scroll Page To Element          css=.action_period
  Input Text                      id=complaintdraft-title  ${complaint_data.data.title}
  Input Text                      id=complaintdraft-description  ${complaint_data.data.description}
  Click Element                   xpath=//button[contains(text(), 'Подати')]
  Wait Until Element Is Visible   id=publisher-info  45
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#questions-complaints']
  Wait Until Page Contains        ${complaint_data.data.title}
  ${complaintId}=                 Get Element Attribute  xpath=//div[@id='qc-claims']/div[last()]@data-complaintid
  [return]                        ${complaintId}

Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  ${user_name}  ${tender_id}  ${complaint_data}  ${lot_id}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_id}
  Wait Until Element Is Visible   id=draftComplaintTender
  Click Element                   id=draftComplaintTender
  Wait Until Element Is Visible   css=.action_period
  Scroll Page To Element          css=.action_period
  Execute Javascript              $("#claim-element").val($("#claim-element :contains('${lot_id}') option").first().attr("value")).change();
  Input Text                      id=complaintdraft-title  ${complaint_data.data.title}
  Input Text                      id=complaintdraft-description  ${complaint_data.data.description}
  Click Element                   xpath=//button[contains(text(), 'Подати')]
  Wait Until Element Is Visible   id=publisher-info  45
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#questions-complaints']
  Wait Until Page Contains        ${complaint_data.data.title}
  ${complaintId}=                 Get Element Attribute  xpath=//div[@id='qc-claims']/div[last()]@data-complaintid
  [return]                        ${complaintId}

Скасувати вимогу
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${cancel_data}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                     xpath=//a[@href='#questions-complaints']
  Wait Until Element Is Visible     xpath=//a[@href='#qc-claims']
  Click Element                     xpath=//a[@href='#qc-claims']
  Wait Until Page Contains Element  xpath=//div[@data-complaintid='${complaint_uaid}']
  Click Element                     xpath=//div[@data-complaintid='${complaint_uaid}']//a[contains(text(), 'Відмінити вимогу')]
  Wait Until Element Is Visible     css=.action_period
  Scroll Page To Element            css=.action_period
  Input Text                        id=complaintcancel-cancellationreason  ${cancel_data.data.cancellationReason}
  Capture Page Screenshot
  Click Element                     xpath=//button[contains(text(), 'Далі')]

Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${cancel_data}
  Скасувати вимогу  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${cancel_data}

Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${cancel_data}
  Скасувати вимогу  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${cancel_data}

Створити вимогу про виправлення визначення переможця
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_data}  ${award_index}  ${file}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#awards']
  Wait Until Element Is Visible   id=draftComplaintAward  10
  Click Element                   id=draftComplaintAward
  Wait Until Element Is Visible   css=.action_period
  Scroll Page To Element          css=.action_period
  Input Text                      id=complaintdraft-title  ${complaint_data.data.title}
  Input Text                      id=complaintdraft-description  ${complaint_data.data.description}
  Execute Javascript              $('.fa-plus').trigger('click');
  Wait Until Element Is Visible   css=.add-item
  Click Element                   css=.add-item
  Wait Until Element Is Visible   css=.delete-document
  Choose File                     css=.document-img  ${file}
  Wait Until Page Contains        Done
  Click Element                   xpath=//button[contains(text(), 'Подати')]
  Wait Until Element Is Visible   id=publisher-info  45
  Scroll To Tabs
  Click Element                   xpath=//a[@href='#awards']
  Wait Until Page Contains        ${complaint_data.data.title}
  ${complaintId}=                 Get Element Attribute  xpath=//div[@class='form_box mrgn-t20']//div[@class='dib']/div[last()]@data-complaintid
  [return]                        ${complaintId}

Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${complaint_data}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                     xpath=//a[@href='#awards']
  Wait Until Page Contains Element  xpath=//div[@data-complaintid='${complaint_uaid}']
  Click Element                     xpath=//div[@data-complaintid='${complaint_uaid}']//a[contains(text(), 'Задоволення вимоги')]
  Wait Until Page Contains          Задоволення вимоги  45
  Scroll Page To Element            css=.action_period
  Sleep                             1
  Run Keyword If  ${complaint_data.data.satisfied}  Click Element  xpath=//div[@id='complaintresolve-satisfied']//input[@value="1"]
  ...   ELSE   Click Element  xpath=//div[@id='complaintresolve-satisfied']//input[@value="0"]
  Sleep  1
  Capture Page Screenshot
  Click Element  xpath=//button[contains(text(), 'Підтвердити')]

Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_data}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору   ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                     xpath=//a[@href='#awards']
  Wait Until Page Contains Element  id=draftComplaintAward
  Click Element                     id=draftComplaintAward
  Wait Until Element Is Visible     css=.action_period
  Scroll Page To Element            css=.action_period
  Input Text                        id=complaintdraft-title  ${complaint_data.data.title}
  Input Text                        id=complaintdraft-description  ${complaint_data.data.description}
  Click Element                     xpath=//button[contains(text(), 'Подати')]
  Wait Until Element Is Visible     id=publisher-info  45
  Scroll To Tabs
  Click Element                     xpath=//a[@href='#awards']
  Wait Until Page Contains          ${complaint_data.data.title}
  ${complaintId}=                   Get Element Attribute  xpath=//div[@class='form_box mrgn-t20']//div[@class='dib']/div[last()]@data-complaintid
  [return]                          ${complaintId}

Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${user_name}  ${tender_uaid}  ${complaint_uaid}  ${cancel_data}  ${award_index}
  ubiz.Пошук тендера по ідентифікатору  ${user_name}  ${tender_uaid}
  Scroll To Tabs
  Click Element                     xpath=//a[@href='#awards']
  Wait Until Page Contains Element  xpath=//div[@data-complaintid='${complaint_uaid}']
  Click Element                     xpath=//div[@data-complaintid='${complaint_uaid}']//a[contains(text(), 'Відмінити вимогу')]
  Wait Until Element Is Visible     css=.action_period
  Scroll Page To Element            css=.action_period
  Input Text                        id=complaintcancel-cancellationreason  ${cancel_data.data.cancellationReason}
  Click Element                     xpath=//button[contains(text(), 'Далі')]