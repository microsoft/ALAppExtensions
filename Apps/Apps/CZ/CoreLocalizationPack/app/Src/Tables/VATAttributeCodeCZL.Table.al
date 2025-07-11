// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 11752 "VAT Attribute Code CZL"
{
    Caption = 'VAT Attribute Code';
    DrillDownPageId = "VAT Attribute Codes CZL";
    LookupPageId = "VAT Attribute Codes CZL";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            NotBlank = true;
            TableRelation = "VAT Statement Template";
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies a VAT attribute code.';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the VAT attribute description.';
        }
        field(4; "XML Code"; Code[20])
        {
            Caption = 'XML Code';
            ToolTip = 'Specifies the XML code for VAT statement reporting.';
        }
        field(5; "VAT Report Amount Type"; Enum "VAT Report Amount Type CZL")
        {
            Caption = 'VAT Return Amount Type';
            ToolTip = 'Specifies the attribute code value to display amounts in corresponding columns of VAT Return.';
        }
    }
    keys
    {
        key(Key1; "VAT Statement Template Name", "Code")
        {
            Clustered = true;
        }
        key(Key2; "XML Code")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

    var
        OutputtaxTxt: Label 'l. %1 - Output tax', Comment = '%1 = line number';
        TaxbaseTxt: Label 'l. %1 - Tax base', Comment = '%1 = line number';
        AcquisitionofgoodstaxbaseTxt: Label 'l. %1 - Acquisition of goods, tax base', Comment = '%1 = line number';
        DeliveryOfGoodsTaxBaseTxt: Label 'l. %1 - Delivery of goods, tax base', Comment = '%1 = line number';
        GoodsImportTaxBaseTxt: Label 'l. %1 - Goods import, tax base', Comment = '%1 = line number';
        CreditorTaxTxt: Label 'l. %1 - Creditor, tax', Comment = '%1 = line number';
        DebtorTaxTxt: Label 'l. %1 - Debtor, tax', Comment = '%1 = line number';
        InfullTxt: Label 'l. %1 - In full', Comment = '%1 = line number';
        ReducedDeductionTxt: Label 'l. %1 - Reduced deduction', Comment = '%1 = line number';
        WithoutClaimOnDeductionTxt: Label 'l. %1 - Without claim on deduction', Comment = '%1 = line number';
        WithClaimOnDeductionTxt: Label 'l. %1 - With claim on deduction', Comment = '%1 = line number';
        DeductionTxt: Label 'l. %1 - Deduction', Comment = '%1 = line number';
        CoefficientTxt: Label 'l. %1 - Coefficient %', Comment = '%1 = line number';
        DeductionChangeTxt: Label 'l. %1 - Deduction change', Comment = '%1 = line number';
        SettlementCoefficientTxt: Label 'l. %1 - Settlement coefficient', Comment = '%1 = line number';
        TaxTxt: Label 'l. %1 - Tax', Comment = '%1 = line number';
        CodeFormatTok: Label '%1-%2%3', Comment = '%1 = code of xml format, %2 = line number with a fixed length of two characters, %3 = abbreviation specifying value on a line', Locked = true;
        DTok: Label 'D', Locked = true;
        ZTok: Label 'Z', Locked = true;
        KTok: Label 'K', Locked = true;
        BTok: Label 'B', Locked = true;
        STok: Label 'S', Locked = true;

    internal procedure GetTaxApendix(): Code[1]
    begin
        exit(DTok);
    end;

    internal procedure GetBaseApendix(): Code[1]
    begin
        exit(ZTok);
    end;

    internal procedure GetReducedApendix(): Code[1]
    begin
        exit(KTok);
    end;

    internal procedure GetNoDeductionApendix(): Code[1]
    begin
        exit(BTok);
    end;

    internal procedure GetDeductionApendix(): Code[1]
    begin
        exit(STok);
    end;

    internal procedure BuildVATAttributeCode(XmlFormatCode: Code[10]; LineNo: Integer; Apendix: Code[1]): Code[20]
    begin
        exit(StrSubstNo(CodeFormatTok, XmlFormatCode, LeftPadCode(Format(LineNo), 2, '0'), Apendix));
    end;

    internal procedure BuildOutputTaxDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(OutputtaxTxt, LineNo));
    end;

    internal procedure BuildTaxBaseDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(TaxbaseTxt, LineNo));
    end;

    internal procedure BuildAcquisitionOfGoodsTaxBaseDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(AcquisitionofgoodstaxbaseTxt, LineNo));
    end;

    internal procedure BuildDeliveryOfGoodsTaxBaseDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(DeliveryOfGoodsTaxBaseTxt, LineNo));
    end;

    internal procedure BuildGoodsImportTaxBaseDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(GoodsImportTaxBaseTxt, LineNo));
    end;

    internal procedure BuildCreditorTaxDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(CreditorTaxTxt, LineNo));
    end;

    internal procedure BuildDebtorTaxDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(DebtorTaxTxt, LineNo));
    end;

    internal procedure BuildInFullDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(InfullTxt, LineNo));
    end;

    internal procedure BuildReducedDeductionDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(ReducedDeductionTxt, LineNo));
    end;

    internal procedure BuildWithoutClaimOnDeductionDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(WithoutClaimOnDeductionTxt, LineNo));
    end;

    internal procedure BuildWithClaimOnDeductionDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(WithClaimOnDeductionTxt, LineNo));
    end;

    internal procedure BuildDeductionDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(DeductionTxt, LineNo));
    end;

    internal procedure BuildCoefficientDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(CoefficientTxt, LineNo));
    end;

    internal procedure BuildDeductionChangeDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(DeductionChangeTxt, LineNo));
    end;

    internal procedure BuildSettlementCoefficientDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(SettlementCoefficientTxt, LineNo));
    end;

    internal procedure BuildTaxDescription(LineNo: Integer): Text[100]
    begin
        exit(BuildDescription(TaxTxt, LineNo));
    end;

    internal procedure ConvertApendixToVATReportAmountType(Apendix: Code[1]): Enum "VAT Report Amount Type CZL"
    begin
        case Apendix of
            GetBaseApendix():
                exit("VAT Report Amount Type CZL"::Base);
            GetTaxApendix(),
            GetDeductionApendix(),
            GetNoDeductionApendix():
                exit("VAT Report Amount Type CZL"::Amount);
            GetReducedApendix():
                exit("VAT Report Amount Type CZL"::"Reduced Amount");
        end;
    end;

    local procedure BuildDescription(DescriptionTxt: Text; LineNo: Integer): Text[100]
    begin
        exit(StrSubstNo(DescriptionTxt, LeftPadCode(Format(LineNo), 3, '0')));
    end;

    local procedure LeftPadCode(String: Text; Length: Integer; FillCharacter: Text): Text;
    begin
        exit(PadStr('', Length - StrLen(String), FillCharacter) + String);
    end;
}
