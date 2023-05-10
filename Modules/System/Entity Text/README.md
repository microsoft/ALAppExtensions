This contains functionality to enable rich text content for entities.

# Public Objects
## Entity Text (Codeunit 2010)

 Exposes the public functionality for handling entity text.
 

### IsEnabled (Method) <a name="IsEnabled"></a> 

 Gets if Entity Text functionality is enabled.
 

#### Syntax
```
procedure IsEnabled(Silent: Boolean): Boolean
```
#### Parameters
*Silent ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

If this should be evaluated silently.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the functionality is enabled.
### IsEnabled (Method) <a name="IsEnabled"></a> 

 Gets if Entity Text functionality is enabled.
 

#### Syntax
```
procedure IsEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the functionality is enabled.
### CanSuggest (Method) <a name="CanSuggest"></a> 

 Gets if the Entity Text Suggest functionality is enabled
 

#### Syntax
```
procedure CanSuggest(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the functionality is enabled.
### GetText (Method) <a name="GetText"></a> 

 Gets the rich text for a given Entity Text.
 

#### Syntax
```
procedure GetText(TableId: Integer; SystemId: Guid; EntityTextScenario: Enum "Entity Text Scenario"): Text
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table for which to retrieve the entity text.

*SystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the entity for which to retrieve the entity text.

*EntityTextScenario ([Enum "Entity Text Scenario"]())* 

The entity text scenario to retrieve the text for.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The rich text content of the entity text (or an empty string if it is not found).
### GetText (Method) <a name="GetText"></a> 

 Gets the rich text for a given Entity Text.
 

#### Syntax
```
procedure GetText(var EntityText: Record "Entity Text"): Text
```
#### Parameters
*EntityText ([Record "Entity Text"]())* 

The entity text record to read the text from.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The rich text content of the entity text.
### OnRequestEntityContext (Event) <a name="OnRequestEntityContext"></a> 

 Event that is raised to build context for the given entity.
 


 Subscribers should check against the table id, system id, and scenario before setting the facts, tone, and format. A runtime error will occur if Handled is false.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnRequestEntityContext(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; var Facts: Dictionary of [Text, Text]; var TextTone: Enum "Entity Text Tone"; var TextFormat: Enum "Entity Text Format"; var Handled: Boolean)
```
#### Parameters
*SourceTableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table of the entity.

*SourceSystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the entity.

*SourceScenario ([Enum "Entity Text Scenario"]())* 

The scenario for which to get context for.

*Facts ([Dictionary of [Text, Text]]())* 

A dictionary of facts to provide about the entity. Only the first 20 facts will be used for text generation.

*TextTone ([Enum "Entity Text Tone"]())* 

The default tone of text to apply to this entity.

*TextFormat ([Enum "Entity Text Format"]())* 

The default text format to apply to this entity.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Set if this scenario was handled.

### OnEditEntityText (Event) <a name="OnEditEntityText"></a> 

 Event that is raised to override the default Edit behavior.
 


 Subscribers should check the Entity Text primary keys (table id, source id, scenario) if you should handle this record before opening a page.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnEditEntityText(var TempEntityText: Record "Entity Text" temporary; var Action: Action; var Handled: Boolean)
```
#### Parameters
*TempEntityText ([Record "Entity Text" temporary]())* 

The Entity Text record to be modified.

*Action ([Action]())* 

Must be set to the resulting action from the edit page (if handled).

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

If the edit event was handled (set to true even if the action was cancelled).


## Azure OpenAi Settings (Page 2010)

 Page for viewing settings for Azure OpenAI.
 


## Entity Text (Page 2013)

 The fallback edit page shown if the OnEditEntityText is not handled.
 Uses the "Entity Text Part" to render the rich text editor.
 


## Entity Text Factbox Part (Page 2011)

 A card part to use on a factbox to display the entity text.
 Ensure the SetContext procedure is called OnAfterGetCurrentRecord on the parent page.
 

### SetContext (Method) <a name="SetContext"></a> 

 Sets the context for the Entity Text Factbox Part.
 

This must be called when including the part or no entity text will be rendered.

#### Syntax
```
procedure SetContext(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; PlaceholderText: Text)
```
#### Parameters
*SourceTableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table for which to retrieve the entity text.

*SourceSystemId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the entity for which to retrieve the entity text.

*SourceScenario ([Enum "Entity Text Scenario"]())* 

The entity text scenario to retrieve the entity text.

*PlaceholderText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The placeholder text to display if no entity text exists.


## Entity Text Part (Page 2012)

 A reusable component to modify entity texts with a rich text editor.
 See the "Entity Text" page for an example implementation.
 

### SetContext (Method) <a name="SetContext"></a> 

 Sets the context for the Entity Text Page Part.
 

Text cannot be suggested without calling SetContext.

#### Syntax
```
procedure SetContext(InitialText: Text; var InitialFacts: Dictionary of [Text, Text]; var InitialTextTone: Enum "Entity Text Tone"; var InitialTextFormat: Enum "Entity Text Format")
```
#### Parameters
*InitialText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The initial text to set in the rich text editor.

*InitialFacts ([Dictionary of [Text, Text]]())* 

The initial facts to use for suggesting text.

*InitialTextTone ([Enum "Entity Text Tone"]())* 

The initial tone of text to use for suggesting text.

*InitialTextFormat ([Enum "Entity Text Format"]())* 

The initial text format to use for suggesting text.

### SetFacts (Method) <a name="SetFacts"></a> 

 Sets the facts used for text suggestion.
 

#### Syntax
```
procedure SetFacts(NewFacts: Dictionary of [Text, Text])
```
#### Parameters
*NewFacts ([Dictionary of [Text, Text]]())* 

The new facts to use.

### SetTextTone (Method) <a name="SetTextTone"></a> 

 Sets the text tone used for text suggestion.
 

#### Syntax
```
procedure SetTextTone(NewTextTone: Enum "Entity Text Tone")
```
#### Parameters
*NewTextTone ([Enum "Entity Text Tone"]())* 

The new text tone to use.

### SetTextFormat (Method) <a name="SetTextFormat"></a> 

 Sets the text format used for text suggestion.
 

#### Syntax
```
procedure SetTextFormat(NewTextFormat: Enum "Entity Text Format")
```
#### Parameters
*NewTextFormat ([Enum "Entity Text Format"]())* 

The new text format to use.

### SetTextEmphasis (Method) <a name="SetTextEmphasis"></a> 

 Sets the text emphasis used for text suggestion.
 

#### Syntax
```
procedure SetTextEmphasis(NewTextEmphasis: Enum "Entity Text Emphasis")
```
#### Parameters
*NewTextEmphasis ([Enum "Entity Text Emphasis"]())* 

The new text emphasis to use.

### SetHasAdvancedOptions (Method) <a name="SetHasAdvancedOptions"></a> 

 Sets whether the parent page has advanced options used for text suggestion.
 

#### Syntax
```
procedure SetHasAdvancedOptions(NewHasAdvancedOptions: Boolean)
```
#### Parameters
*NewHasAdvancedOptions ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

If the parent page has advanced options to use.

### ShowAdvancedOptions (Method) <a name="ShowAdvancedOptions"></a> 

 Gets whether the advanced options should be visible.
 


 If the parent page has advanced options, it is recommended to check this OnAfterGetCurrRecord.
 Additionally, UpdatePropagation should be set to Both on the part.
 This way, the part can notify the parent when the state changes.
 

#### Syntax
```
procedure ShowAdvancedOptions(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the advanced options should be shown.
### UpdateRecord (Method) <a name="UpdateRecord"></a> 

 Updates the Entity Text record with the current text.
 

#### Syntax
```
procedure UpdateRecord(var EntityText: Record "Entity Text")
```
#### Parameters
*EntityText ([Record "Entity Text"]())* 

The entity text record to update.

### SetContentCaption (Method) <a name="SetContentCaption"></a> 

 Sets the field caption on the rich text editor.
 

The caption specified here will also be used for the placeholder text in the editor if it is empty.

#### Syntax
```
procedure SetContentCaption(NewCaption: Text)
```
#### Parameters
*NewCaption ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption to use.


## Entity Text Emphasis (Enum 2012)

 Enum containing supported ways to emphasize text for generation.
 

### None (value: 0)


 Do not emphasize a particular quality.
 

### Innovation (value: 1)


 Emphasizes innovation.
 

### Sustainability (value: 2)


 Emphasizes sustainability.
 

### Power (value: 3)


 Emphasizes power.
 

### Elegance (value: 4)


 Emphasizes elegance.
 

### Reliability (value: 5)


 Emphasizes reliability.
 

### Speed (value: 6)


 Emphasizes speed.
 


## Entity Text Format (Enum 2010)

 Enum containing supported text formats for generation.
 

### Tagline (value: 0)


 Generate a short tagline.
 

### Paragraph (value: 1)


 Generate a paragraph of text.
 

### TaglineParagraph (value: 2)


 Generate a tagline and paragraph in one prompt.
 

### Brief (value: 3)


 Generate a brief summary.
 


## Entity Text Tone (Enum 2011)

 Enum containing supported tones of text for generation.
 

### Formal (value: 0)


 The tone of voice should be formal.
 

### Casual (value: 1)


 The tone of voice should be casual.
 

### Inspiring (value: 2)


 The tone of voice should be inspiring.
 

### Upbeat (value: 3)


 The tone of voice should be upbeat.
 

### Creative (value: 4)


 The tone of voice should be creative.
 

