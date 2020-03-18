table 10676 "SAF-T Mapping Range"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Mapping Range';
    LookupPageId = "SAF-T Mapping Setup";
    DrillDownPageId = "SAF-T Mapping Setup";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Mapping Type"; Enum "SAF-T Mapping Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Type';

            trigger OnValidate()
            var
                SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
                SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
            begin
                if "Mapping Type" <> xRec."Mapping Type" then begin
                    SAFTMappingHelper.VerifyNoMappingDone(xRec);
                    SAFTGLAccountMapping.SetRange("Mapping Range Code", Code);
                    SAFTGLAccountMapping.ModifyAll("Mapping Type", "Mapping Type");
                end;
            end;
        }
        field(3; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                CheckDateConsistency();
                if "Starting Date" = 0D then
                    "Range Type" := 0
                else begin
                    "Accounting Period" := 0D;
                    "Range Type" := "Range Type"::"Date Range";
                end;
            end;
        }
        field(4; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                CheckDateConsistency();
                if "Ending Date" = 0D then
                    "Range Type" := 0
                else begin
                    "Accounting Period" := 0D;
                    "Range Type" := "Range Type"::"Date Range";
                end;
            end;
        }
        field(5; "Range Type"; Enum "SAF-T Mapping Range")
        {
            DataClassification = CustomerContent;
            Caption = 'Range Type';
            Editable = false;
        }
        field(6; "Accounting Period"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Accounting Period';
            TableRelation = "Accounting Period" where ("New Fiscal Year" = const (true));

            trigger OnValidate()
            var
                AccountingPeriod: Record "Accounting Period";
            begin
                if "Accounting Period" = 0D then
                    "Range Type" := 0
                else begin
                    "Range Type" := "Range Type"::"Accounting Period";
                    AccountingPeriod.get("Accounting Period");
                    "Starting Date" := AccountingPeriod."Starting Date";
                    "Ending Date" := AccountingPeriod.GetFiscalYearEndDate("Starting Date");
                    if "Ending Date" = 0D then
                        error(CannotSelectAccPeriodWithoutEndingDateErr);
                end;
            end;
        }
        field(7; "Include Incoming Balance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Include Incoming Balance';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, "Range Type", "Starting Date", "Ending Date")
        {

        }
    }

    var
        DatesAreNotCorrectErr: Label 'Starting date cannot be before ending date.';
        MappingExistQst: Label 'One or more G/L Account already mapped. Do you want to remove the mapping range?';
        SAFTExportsExistsErr: Label 'One or more SAF-T exports exist for the mapping range. Do you want to remove the mapping range?';
        CannotSelectAccPeriodWithoutEndingDateErr: Label 'You cannot select the accounting period that does not have the ending date.';

    trigger OnDelete()
    var
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTExportHeader: Record "SAF-T Export Header";
    begin
        SAFTExportHeader.SetRange("Mapping Range Code", Code);
        if not SAFTExportHeader.IsEmpty() then
            if Confirm(SAFTExportsExistsErr) then
                SAFTExportHeader.DeleteAll(true)
            else
                Error('');
        SAFTGLAccountMapping.SetRange("Mapping Range Code", Code);
        if not SAFTGLAccountMapping.IsEmpty() then
            if Confirm(MappingExistQst) then
                SAFTGLAccountMapping.DeleteAll(true)
            else
                Error('');

    end;

    procedure CheckMappingIsStandardAccount()
    begin
        if not IsStandardAccountMapping() then
            FieldError("Mapping Type");
    end;

    procedure IsStandardAccountMapping(): Boolean
    begin
        exit("Mapping Type" IN ["Mapping Type"::"Two Digit Standard Account", "Mapping Type"::"Four Digit Standard Account"]);
    end;

    procedure GetSAFTMappingSourceTypeByMappingType(): Enum "SAF-T Mapping Source Type"
    var
        SAFTMappingSourceType: Enum "SAF-T Mapping Source Type";
    begin
        case "Mapping Type" of
            "Mapping Type"::"Two Digit Standard Account":
                exit(SAFTMappingSourceType::"Two Digit Standard Account");
            "Mapping Type"::"Four Digit Standard Account":
                exit(SAFTMappingSourceType::"Four Digit Standard Account");
            "Mapping Type"::"Income Statement":
                exit(SAFTMappingSourceType::"Income Statement");
        end;
    end;

    local procedure CheckDateConsistency()
    begin
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) and ("Starting Date" > "Ending Date") then
            error(DatesAreNotCorrectErr);
    end;
}
