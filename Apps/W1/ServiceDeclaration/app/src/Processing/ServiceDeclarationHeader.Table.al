table 5023 "Service Declaration Header"
{

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            TableRelation = "VAT Reports Configuration"."VAT Report Version" WHERE("VAT Report Type" = CONST("Service Declaration"));
        }
        field(50; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(51; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        field(100; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(101; "Created Date-Time"; DateTime)
        {
            Caption = 'Created Date-Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            ServiceDeclarationSetup.Get();
            ServiceDeclarationSetup.TestField("Declaration No. Series");
            NoSeriesMgt.InitSeries(ServiceDeclarationSetup."Declaration No. Series", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    procedure SuggestLines()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        TestField("Starting Date");
        TestField("Ending Date");
        GetServDeclarationConfig(VATReportsConfiguration);
        VATReportsConfiguration.TestField("Suggest Lines Codeunit ID");
        Codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", Rec);
    end;

    procedure CreateFile()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        GetServDeclarationConfig(VATReportsConfiguration);
        if VATReportsConfiguration."Content Codeunit ID" <> 0 then
            Codeunit.Run(VATReportsConfiguration."Content Codeunit ID", Rec);
        if VATReportsConfiguration."Submission Codeunit ID" <> 0 then
            Codeunit.Run(VATReportsConfiguration."Submission Codeunit ID", Rec);
    end;

    local procedure GetServDeclarationConfig(var VATReportsConfiguration: Record "VAT Reports Configuration")
    begin
        TestField("Config. Code");
        VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type"::"Service Declaration", "Config. Code");
    end;
}

