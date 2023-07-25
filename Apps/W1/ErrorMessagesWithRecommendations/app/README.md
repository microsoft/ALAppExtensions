Use the actionable error messages displayed on the Error Messages page to resolve the issue and continue working.

## How to add error messages with fix implementation?
1. Implement the `interface ErrorMessageFix` and extend `enum 7901 "Error Msg. Fix Implementation"`
1. Make sure the extended fields (`tableextension 7900 "Error Message Ext."`) for the logged error message record has been populated.
1. Use drill down on the recommended actions column or the Accept recommendations action on the error message page to fix the errors.

---
## Technical details and usage
### `interface ErrorMessageFix`
To add a logic to fix the error, implement this interface in a codeunit. 
Extend the `enum 7901 "Error Msg. Fix Implementation"` to include the implemented codeunit.

### Base Application's `ErrorMessageManagement.Codeunit.al`
```
procedure AddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant)
```
It can be used to add sub-context information and the implementation for the error message action to the last logged error message. This triggers the `OnAddSubContextToLastErrorMessage` event.

### Usage in Base Application:
`ErrorMessageMgt.AddSubContextToLastErrorMessage(...)` is used in `DimensionManagement.Codeunit.al` to log `SameCodeWrongDimErr` and `NoCodeFilledDimErr` by passing the Sub-Context information. Dimension Set Entry is the sub-context for these error messages.

#### Event `OnAddSubContextToLastErrorMessage(Tag, VariantRec, TempErrorMessage)`
Use `Tag` to identify the error message in the subscriber. `VariantRec` can be used to pass the sub-context information. `TempErrorMessage` is the error message record under consideration.

### Usage in this extension:
#### `codeunit 7903 "Dimension Code Same Error"` and `codeunit 7904 "Dimension Code Must Be Blank"`
Subscribe to the event `OnAddSubContextToLastErrorMessage`. Update the error message record based on the `Tag`.
Set the `TempErrorMessage."Error Msg. Fix Implementation"` to use enum value from `enum 7901 "Error Msg. Fix Implementation"` which has the implementation for the error message action.

### `codeunit 7900 ErrorMessagesActionHandler`
This handles the drill down operation and the accept recommended action on the Error Messages Page.
```
procedure OnActionDrillDown(var ErrorMessage: Record "Error Message")
```
Drill down to the recommended action of an error message to execute it with a confirmation dialog box. When user confirms the action, the error message fix implementation is executed for the selected error message.

```
procedure ExecuteActions(var ErrorMessages: Record "Error Message" temporary)
```
Execute recommended actions for all the selected error messages on the page.
Selected error messages are passed from the page and all the error message fix implementations are executed for the selected error messages.
The procedure does not stop if there is an error in applying fix. Instead, it updates the error message status and continues to apply remaining recommendations for the remaining error messages.

### `codeunit 7901 "Execute Error Action"`
This codeunit is internally used to execute the error message fix implementation with ErrorBehavior::Collect. This allows us to continue applying recommendations for all the selected error messages even if there is an error.
**Note:** Commits will be ignored inside the implementation of ErrorMessageFix interface.


