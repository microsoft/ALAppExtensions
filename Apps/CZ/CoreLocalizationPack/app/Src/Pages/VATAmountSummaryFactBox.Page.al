// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using System.Utilities;

page 31046 "VAT Amount Summary FactBox CZL"
{
    Caption = 'VAT Amount Summary';
    PageType = ListPart;
    SourceTableTemporary = true;
    SourceTable = Integer;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(VATRate; VATRate)
                {
                    Caption = 'VAT %';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant VAT rate.';
                }
                field(VATAmountTotal; VATAmountTotal)
                {
                    Caption = 'Corrected VAT Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the corrected VAT amount total per VAT rate.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if VATRateList.Get(Rec.Number, VATRate) then
            VATAmountTotalDictionary.Get(VATRate, VATAmountTotal)
    end;

    var
        VATRate: Decimal;
        VATAmountTotal: Decimal;
        VATAmountTotalDictionary: Dictionary of [Decimal, Decimal];
        VATRateList: List of [Decimal];


    procedure UpdateVATAmountTotals(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    var
        i: Integer;
    begin
        Clear(VATAmountTotalDictionary);
        if VATLCYCorrectionBufferCZL.FindSet() then
            repeat
                if VATAmountTotalDictionary.Get(VATLCYCorrectionBufferCZL."VAT %", VATAmountTotal) then
                    VATAmountTotalDictionary.Set(VATLCYCorrectionBufferCZL."VAT %", VATAmountTotal + VATLCYCorrectionBufferCZL."Corrected VAT Amount")
                else
                    VATAmountTotalDictionary.Add(VATLCYCorrectionBufferCZL."VAT %", VATLCYCorrectionBufferCZL."Corrected VAT Amount");
            until VATLCYCorrectionBufferCZL.Next() = 0;

        Rec.DeleteAll();
        VATRateList := VATAmountTotalDictionary.Keys;
        foreach VATRate in VATRateList do begin
            i += 1;
            Rec.Init();
            Rec.Number := i;
            Rec.Insert();
        end;
    end;
}

