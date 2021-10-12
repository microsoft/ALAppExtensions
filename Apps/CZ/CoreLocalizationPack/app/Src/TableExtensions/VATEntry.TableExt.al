tableextension 11737 "VAT Entry CZL" extends "VAT Entry"
{
    fields
    {
        field(11710; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11711; "VAT Settlement No. CZL"; Code[20])
        {
            Caption = 'VAT Settlement No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11712; "VAT Delay CZL"; Boolean)
        {
            Caption = 'VAT Delay';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11726; "VAT Identifier CZL"; Code[20])
        {
            Caption = 'VAT Identifier';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "EU 3-Party Intermed. Role CZL" then
                    "EU 3-Party Trade" := true;
            end;
        }
        field(31110; "VAT Ctrl. Report No. CZL"; Code[20])
        {
            CalcFormula = lookup("VAT Ctrl. Report Ent. Link CZL"."VAT Ctrl. Report No." where("VAT Entry No." = field("Entry No.")));
            Caption = 'VAT Control Report No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31111; "VAT Ctrl. Report Line No. CZL"; Integer)
        {
            CalcFormula = lookup("VAT Ctrl. Report Ent. Link CZL"."Line No." where("VAT Entry No." = field("Entry No.")));
            Caption = 'VAT Control Report Line No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
    var
        VATStmtPeriodSelectionNotSupportedErr: Label 'VAT statement report period selection %1 is not supported.', Comment = '%1 = VAT Statement Report Period Selection';
        VATStmtReportSelectionNotSupportedErr: Label 'VAT statement report selection %1 is not supported.', Comment = '%1 = VAT Statement Report Selection';

    procedure SetVATStatementLineFiltersCZL(VATStatementLine: Record "VAT Statement Line")
    begin
        SetRange(Type, VATStatementLine."Gen. Posting Type");
        SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
        SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
        SetRange("Tax Jurisdiction Code", VATStatementLine."Tax Jurisdiction Code");
        SetRange("Use Tax", VATStatementLine."Use Tax");
        if VATStatementLine."Gen. Bus. Posting Group CZL" <> '' then
            SetRange("Gen. Bus. Posting Group", VATStatementLine."Gen. Bus. Posting Group CZL");
        if VATStatementLine."Gen. Prod. Posting Group CZL" <> '' then
            SetRange("Gen. Prod. Posting Group", VATStatementLine."Gen. Prod. Posting Group CZL");
        SetRange("EU 3-Party Trade");
        case VATStatementLine."EU-3 Party Trade CZL" of
            VATStatementLine."EU-3 Party Trade CZL"::Yes:
                SetRange("EU 3-Party Trade", true);
            VATStatementLine."EU-3 Party Trade CZL"::No:
                SetRange("EU 3-Party Trade", false);
        end;
        SetRange("EU 3-Party Intermed. Role CZL");
        case VATStatementLine."EU 3-Party Intermed. Role CZL" of
            VATStatementLine."EU 3-Party Intermed. Role CZL"::Yes:
                SetRange("EU 3-Party Intermed. Role CZL", true);
            VATStatementLine."EU 3-Party Intermed. Role CZL"::No:
                SetRange("EU 3-Party Intermed. Role CZL", false);
        end;
        OnAfterSetVATStatementLineFiltersCZL(Rec, VATStatementLine);
    end;

    procedure SetPeriodFilterCZL(VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection"; StartDate: Date; EndDate: Date; UseVATDate: Boolean)
    var
        IsHandled: Boolean;
    begin
        case VATStatementReportPeriodSelection of
            VATStatementReportPeriodSelection::"Before and Within Period":
                SetDateFilterCZL(0D, EndDate, UseVATDate);
            VATStatementReportPeriodSelection::"Within Period":
                SetDateFilterCZL(StartDate, EndDate, UseVATDate);
            else begin
                    IsHandled := false;
                    OnSetVATStatementReportPeriodSelectionFilterCaseCZL(Rec, VATStatementReportPeriodSelection, StartDate, EndDate, UseVATDate, IsHandled);
                    if not IsHandled then
                        Error(VATStmtPeriodSelectionNotSupportedErr, VATStatementReportPeriodSelection);
                end;
        end;
    end;

    procedure SetDateFilterCZL(StartDate: Date; EndDate: Date; UseVATDate: Boolean)
    begin
        if UseVATDate then
            SetRange("VAT Date CZL", StartDate, EndDate)
        else
            SetRange("Posting Date", StartDate, EndDate);
    end;

    procedure SetClosedFilterCZL(VATStatementReportSelection: Enum "VAT Statement Report Selection")
    var
        IsHandled: Boolean;
    begin
        case VATStatementReportSelection of
            VATStatementReportSelection::Open:
                SetRange(Closed, false);
            VATStatementReportSelection::Closed:
                SetRange(Closed, true);
            VATStatementReportSelection::"Open and Closed":
                SetRange(Closed);
            else
                IsHandled := false;
                OnSetVATStatementReportSelectionFilterCaseCZL(Rec, VATStatementReportSelection, IsHandled);
                if not IsHandled then
                    Error(VATStmtReportSelectionNotSupportedErr, VATStatementReportSelection);
        end;
    end;

    procedure GetVATBaseCZL(): Decimal
    begin
        if "Unrealized Base" <> 0 then
            exit("Unrealized Base");
        exit(Base);
    end;

    procedure GetVATAmountCZL(): Decimal
    begin
        if "Unrealized Amount" <> 0 then
            exit("Unrealized Amount");
        exit(Amount);
    end;

    procedure IsAdvanceEntryCZL(): Boolean
    var
        AdvanceEntry: Boolean;
    begin
        AdvanceEntry := false;
#if not CLEAN19
#pragma warning disable AL0432
        AdvanceEntry := "Advance Letter No." <> '';
#pragma warning restore AL0432
#endif
        OnAfterGetIsAdvanceEntryCZL(Rec, AdvanceEntry);
        exit(AdvanceEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetVATStatementLineFiltersCZL(var VATEntry: Record "VAT Entry"; VATStatementLine: Record "VAT Statement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetVATStatementReportPeriodSelectionFilterCaseCZL(var VATEntry: Record "VAT Entry"; VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection"; StartDate: Date; EndDate: Date; UseVATDate: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetVATStatementReportSelectionFilterCaseCZL(var VATEntry: Record "VAT Entry"; VATStatementReportSelection: Enum "VAT Statement Report Selection"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetIsAdvanceEntryCZL(VATEntry: Record "VAT Entry"; var AdvanceEntry: Boolean)
    begin
    end;
}
