// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Setup;

page 5283 "VAT Posting Setup SAF-T"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    SourceTable = "VAT Posting Setup";
    Caption = 'VAT Posting Setup SAF-T';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT product posting group. Links business transactions made for the item, resource, or G/L account with the general ledger, to account for VAT amounts resulting from trade with that record.';
                    Editable = false;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how VAT will be calculated for purchases or sales of items with this particular combination of VAT business posting group and VAT product posting group.';
                    Editable = false;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant VAT rate for the particular combination of VAT business posting group and VAT product posting group. Do not enter the percent sign, only the number. For example, if the VAT rate is 25 %, enter 25 in this field.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the VAT posting setup';
                    Editable = false;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the VAT posting setup entry. It will be used for the EffectiveDate XML node in the SAF-T file.';
                    ShowMandatory = StartingDateMandatory;
                }
                field("Sale VAT Reporting Code"; Rec."Sale VAT Reporting Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the sales VAT entries.';
                    ShowMandatory = true;
                }
                field("Purch. VAT Reporting Code"; Rec."Purch. VAT Reporting Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the purchase VAT entries.';
                    ShowMandatory = true;
                }
                field("Sales VAT Code SAF-T"; Rec."Sales Tax Code SAF-T")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the TaxCode XML node in the SAF-T file for the sales VAT entries.';
                    Editable = false;
                }
                field("Purchase VAT Code SAF-T"; Rec."Purchase Tax Code SAF-T")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the TaxCode XML node in the SAF-T file for the purchase VAT entries.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        StartingDateMandatory: Boolean;
        NOCountryCodeTxt: label 'NO', Locked = true;
        DKCountryCodeTxt: label 'DK', Locked = true;

    trigger OnAfterGetRecord()
    begin
        SetFieldsMandatory();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetFieldsMandatory();
    end;

    local procedure SetFieldsMandatory()
    var
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        CountryCode: Text;
    begin
        CountryCode := SAFTDataMgt.GetEnvironmentCountryCode();
        case CountryCode of
            NOCountryCodeTxt:
                StartingDateMandatory := false;
            DKCountryCodeTxt:
                StartingDateMandatory := true;
        end;
    end;
}
