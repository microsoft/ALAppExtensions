Defines how the CaptionClass property displays captions for pages and tables. You can define rules for how captions display.

# Public Objects
## Caption Class (Codeunit 42)

 Exposes events that can be used to resolve custom CaptionClass properties.
 

### OnResolveCaptionClass (Event) <a name="OnResolveCaptionClass"></a> 

 Integration event for resolving CaptionClass expression, split into CaptionArea and CaptionExpr.
 Note there should be a single subscriber per caption area.
 The event implements the "resolved" pattern - if a subscriber resolves the caption, it should set Resolved to TRUE.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
```
#### Parameters
*CaptionArea ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption area used in the CaptionClass expression. Should be unique for every subscriber.

*CaptionExpr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The caption expression used for resolving the CaptionClass expression.

*Language ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The current language ID that can be used for resolving the CaptionClass expression.

*Caption ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter - the resolved caption

*Resolved ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Boolean for marking whether the CaptionClass expression was resolved.

### OnAfterCaptionClassResolve (Event) <a name="OnAfterCaptionClassResolve"></a> 

 Integration event for after resolving CaptionClass expression.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterCaptionClassResolve(Language: Integer; CaptionExpression: Text; var Caption: Text[1024])
```
#### Parameters
*Language ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The current language ID.

*CaptionExpression ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The original CaptionClass expression.

*Caption ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The resolved caption expression.

