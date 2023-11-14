// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// Page for getting the reason for deactivation of a copilot capability.
/// </summary>
page 7772 "Copilot Deactivate Capability"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(Deactivate)
            {
                InstructionalText = 'Please choose a reason so we can improve the capability:';

                field(DeactivateReason; DeactivateOption)
                {
                    ApplicationArea = All;
                    Caption = 'Reason for deactivating';
                    ToolTip = 'Specifies the reason for deactivating the capability.';
                    OptionCaption = ',Not relevant to our business,Users are not ready for it yet,Performance is not good enough,There are privacy concerns,Suggestions not accurate enough,Suggestions are not helpful,Suggestions are offensive or inappropriate,Prefer not to give a reason,Our reason is not listed here';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if DeactivateOption = 0 then
                Error(NoReasonSelecedErr);
    end;

    var
        DeactivateOption: Option;
        DeactivateLbl: Label 'Deactivate %1', Comment = '%1 = the name of the Copilot capability';
        NoReasonSelecedErr: Label 'Please select a reason for deactivating the capability.';

    internal procedure SetCaption(CapabilityName: Text)
    begin
        Caption(StrSubstNo(DeactivateLbl, CapabilityName));
    end;

    internal procedure GetReason(): Option
    begin
        exit(DeactivateOption);
    end;
}