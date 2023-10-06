// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5281 "Data Check SAF-T"
{
    PageType = ConfirmationDialog;
    InstructionalText = 'The following fields are not set up correctly for SAF-T. Do you want to fill them in now?';
    Caption = 'Data Check SAF-T';

    layout
    {
        area(content)
        {
            group(Details)
            {
                ShowCaption = false;
                field(MissedValuesListControl; MissedValuesList)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Missed values';
                    Editable = false;
                    ToolTip = 'Specifies the values you missed you specify.';
                }
                field(TurnOffNotificationMsgControl; TurnOffNotificationMsg)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        MissedValuesList: Text;
        TurnOffNotificationMsg: label 'You can turn-off this notification in the SAF-T Setup page.';

    procedure SetMissedValuesList(NewMissedValuesList: Text)
    begin
        MissedValuesList := NewMissedValuesList;
    end;
}
