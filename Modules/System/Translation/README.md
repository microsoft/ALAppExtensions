# Translation Module

This module lets you add and modify language translations for user data, so that people in different reguions can understand the data. For example, this is useful for descriptions of items that you sell, or for providing standard operating procedures in factories located in different regions. 

## What has been done

Developers can identify the fields for which to enable translations, and then add a calculated field on the page to show the translations. 


## What the module provides

The Translation module provides capabilities for: 

- Setting translations for a specified field on a record, and a given language. 
- Fetching and showing up the translations for a field on a record. 
- Deleting all translations for a record or for a specified field on it 
- Showing the Translations page for a specified field on all records in a table 
- Checking whether any translations are available  

The Translation page shows the **Target Language** field, which contains the target language, and the **Value** field, which is the translation. Note that the translation can only be added for a record that is persisted on the database, and not for temporary records. 

## Usage Example

Page `1801` `Assisted Setup` in the Assisted Setup module shows the translations for each record using a page field `TranslatedName`. The code examples below show how to make this new field lookup other translations, how to populate the field from the Translation module the first time the page is opened, and how to set the translation for a given field from code. 

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

The value is populated during the trigger:

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

The translations are added to each record by calling the appropriate API in the Assisted Setup, which in turn calls the following on Codeunit `1813` `Assisted Setup Impl.`

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