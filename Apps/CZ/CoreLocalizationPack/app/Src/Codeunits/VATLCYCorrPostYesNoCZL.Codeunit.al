// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.GeneralLedger.Preview;
using System.Utilities;

codeunit 31012 "VAT LCY Corr.-Post(Yes/No) CZL"
{
    EventSubscriberInstance = Manual;
    TableNo = "VAT LCY Correction Buffer CZL";

    trigger OnRun()
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(PostingConfirmQst, Rec."Document Type", Rec."Document No."), false) then
            Error('');
        Codeunit.Run(Codeunit::"VAT LCY Correction-Post CZL", Rec);
        Commit();
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        PostingConfirmQst: Label 'Do you want to post VAT correction in LCY for %1 %2?', Comment = '%1 = Document Type; %2 = Document No.';

    procedure Preview(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    var
        VATLCYCorrPostYesNoCZL: Codeunit "VAT LCY Corr.-Post(Yes/No) CZL";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(VATLCYCorrPostYesNoCZL);
        GenJnlPostPreview.Preview(VATLCYCorrPostYesNoCZL, VATLCYCorrectionBufferCZL);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnPreviewRun(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        VATLCYCorrectionPostCZL: Codeunit "VAT LCY Correction-Post CZL";
    begin
        VATLCYCorrectionPostCZL.SetPreviewMode(true);
        Result := VATLCYCorrectionPostCZL.Run(RecVar);
    end;
}
