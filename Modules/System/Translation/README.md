# Introduction
This module lets you add and modify language translations for user data, so that people in different regions can understand the data. For example, this is useful for descriptions of items that you sell, or for providing standard operating procedures in factories located in different regions. 

# What has been done
Developers can identify the fields for which to enable translations, and then add a calculated field on the page to show the translations. 
 
The Translation module provides capabilities for: 
 - Setting translations for a specified field on a record, and a given language. 
 - Fetching and showing up the translations for a field on a record. 
 - Deleting all translations for a record or for a specified field on it. 
 - Showing the Translations page for a specified field on all records in a table. 
 - Checking whether any translations are available.

The Translation page shows the "Target Language" field, which contains the target language, and the "Value" field, which is the translation. Note that the translation can only be added for a record that is persisted on the database, and not for temporary records. 
# Usage example
Page 1801 "Assisted Setup" in the Assisted Setup module shows the translations for each record using a page field TranslatedName. The code examples below show how to make this new field lookup other translations, how to populate the field from the Translation module the first time the page is opened, and how to set the translation for a given field from code. 
```
    field(TranslatedName; TranslatedName)     
    {     
        Caption = 'Translated Name';         
        ApplicationArea = All; 
        ToolTip = 'Specifies the name translated locally.';  

        trigger OnDrillDown() 
        var 
            Translation: Codeunit Translation; 
        begin 
            Translation.Show(Rec, FieldNo(Name)); 
        end; 
    } 
```

The value is populated during the trigger,
```
    trigger OnAfterGetRecord() 
    var 
        Translation: Codeunit Translation; 
    begin 
        HelpAvailable := ''; 
        VideoAvailable := ''; 
        if "Help Url" <> '' then 
            HelpAvailable := HelpLinkTxt; 
        if "Video Url" <> '' then 
            VideoAvailable := VideoLinkTxt; 
        TranslatedName := Translation.Get(Rec, FieldNo(Name)); 
    end; 
```

The translations are added to each record by calling the appropriate API in the Assisted Setup, which in turn calls the following on Codeunit 1813 �Assisted Setup Impl.� 
```
    procedure AddSetupAssistantTranslation(ExtensionId: Guid; PageID: Integer; LanguageID: Integer; TranslatedName: Text) 
    var 
        AssistedSetup: Record "Assisted Setup"; 
        Translation: Codeunit Translation; 
    begin 
        if not AssistedSetup.Get(PageID) then 
            exit; 
        if LanguageID <> GlobalLanguage() THEN 
            Translation.Set(AssistedSetup, AssistedSetup.FIELDNO(Name), LanguageID, TranslatedName); 
    end; 
```

# Public Objects
## Translation (Codeunit 3711)

 Exposes function\alitys to add and retrieve translated texts for table fields.
 

### Any (Method) <a name="Any"></a> 

 Checks if there any translations present at all.
 

#### Syntax
```
procedure Any(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if there is at least one translation; false, otherwise.
### Get (Method) <a name="Get"></a> 

 To get the value of the description field for an item record, call GetValue(Item, Item.FIELDNO(Description)).
 

If the RecVariant parameter is the type Record, and it is temporary.


 Gets the value of a field in the global language for the record.
 


 If a translated record for the global language cannot be found it finds the Windows language translation.
 If a Windows language translation cannot be found, return an empty string.
 

#### Syntax
```
procedure Get(RecVariant: Variant; FieldId: Integer): Text
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to get the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field for which the translation is stored.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The translated value.
### Get (Method) <a name="Get"></a> 

 To get the value of the Description field for an item record in Danish, call GetValue(Item, Item.FIELDNO(Description), 1030).
 

If the RecVariant parameter is the type Record, and it is temporary.


 Gets the value of a field in the language that is specified for the record.
 

#### Syntax
```
procedure Get(RecVariant: Variant; FieldId: Integer; LanguageId: Integer): Text
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to get the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to store the translation for.

*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language in which to get the field value.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The translated value.
### Set (Method) <a name="Set"></a> 
If the RecVariant parameter is the type Record, and it is temporary.


 Sets the value of a field to the global language for the record.
 

#### Syntax
```
procedure Set(RecVariant: Variant; FieldId: Integer; Value: Text[2048])
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to store the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to store the translation for.

*Value ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated value to set.

### Set (Method) <a name="Set"></a> 
If the RecVariant parameter is the type Record, and it is temporary.


 Sets the value of a field to the language specified for the record.
 

#### Syntax
```
procedure Set(RecVariant: Variant; FieldId: Integer; LanguageId: Integer; Value: Text[2048])
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to store the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to store the translation for.

*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language id to set the value for.

*Value ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated value to set.

### Delete (Method) <a name="Delete"></a> 
If the RecVariant parameter is the type Record, and it is temporary.


 Deletes all translations for a persisted (non temporary) record.
 

#### Syntax
```
procedure Delete(RecVariant: Variant)
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record for which the translations will be deleted.

### Delete (Method) <a name="Delete"></a> 
If the RecVariant parameter is the type Record, and it is temporary.


 Deletes the translation for a field on a persisted (non temporary) record.
 

#### Syntax
```
procedure Delete(RecVariant: Variant; FieldId: Integer)
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record with a field for which the translation will be deleted.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Id of the field for which the translation will be deleted.

### Copy (Method) <a name="Copy"></a> 
If the RecVariant parameter is of type Record, and it is temporary.


 Copies the translation for a field from one record to another record on a persisted (non-temporary) record.
 

#### Syntax
```
procedure Copy(FromRecVariant: Variant; ToRecVariant: Variant)
```
#### Parameters
*FromRecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record from which the translations are copied.

*ToRecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to which the translations are copied.

### Copy (Method) <a name="Copy"></a> 
If the RecVariant parameter is of type Record, and it is temporary.


 Copies the translation for a field from one record to another record on a persisted (non-temporary) record.
 

#### Syntax
```
procedure Copy(FromRecVariant: Variant; ToRecVariant: Variant; FieldId: Integer)
```
#### Parameters
*FromRecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record from which the translations are copied.

*ToRecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to which the translations are copied.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Id of the field for which the translation will be copied.

### Copy (Method) <a name="Copy"></a> 

 Copies the translation from one record's field to another record's field on a persisted (non-temporary) record.
 

#### Syntax
```
procedure Copy(FromRecVariant: Variant; FromFieldId: Integer; ToRecVariant: Variant; ToFieldId: Integer)
```
#### Parameters
*FromRecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record from which the translations are copied.

*FromFieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The id of the field from which the translations are copied.

*ToRecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to which the translations are copied.

*ToFieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The id of the field to which the translations are copied.

### Show (Method) <a name="Show"></a> 
If the RecVariant parameter is the type Record, and it is temporary.


 Shows all language translations that are available for a field in a new page.
 

#### Syntax
```
procedure Show(RecVariant: Variant; FieldId: Integer)
```
#### Parameters
*RecVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to get the translated value for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to get translations for.

### ShowForAllRecords (Method) <a name="ShowForAllRecords"></a> 

 Shows all language translations available for a given field for all the records in that table in a new page.
 

#### Syntax
```
procedure ShowForAllRecords(TableId: Integer; FieldId: Integer)
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table ID to get translations for.

*FieldId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the field to get translations for.


## Translation (Page 3712)
This page shows the target language and the translation for data in a table field.

### SetCaption (Method) <a name="SetCaption"></a> 

 Sets the page's caption.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetCaption(CaptionText: Text)
```
#### Parameters
*CaptionText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption to set.

