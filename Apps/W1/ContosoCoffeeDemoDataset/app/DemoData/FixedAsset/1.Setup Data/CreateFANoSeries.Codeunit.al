codeunit 4780 "Create FA No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(FixedAsset(), FixedAssetLbl, 'FA000010', 'FA999990', '', '', 10, enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(Insurance(), InsuranceLbl, 'INS000010', 'INS999990', '', '', 10, enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(FixedAssetGLJournal(), FixedAssetGLJournalLbl, 'F00001', 'F01000', '', '', 1, enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(RecurringFixedAssetGLJournal(), RecurringFixedAssetGLJournalLbl, 'RF00001', 'RF01000', '', '', 1, enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(InsuranceJournal(), InsuranceJournalLbl, 'N00001', 'N01000', '', '', 1, enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(FixedAssetJournal(), FixedAssetJournalLbl, 'G05001', 'G06000', '', '', 1, enum::"No. Series Implementation"::Normal, true);
    end;

    procedure FixedAsset(): Code[20]
    begin
        exit(FixedAssetTok);
    end;

    procedure Insurance(): Code[20]
    begin
        exit(InsuranceTok);
    end;

    procedure FixedAssetGLJournal(): Code[20]
    begin
        exit(FixedAssetGLJournalTok);
    end;

    procedure RecurringFixedAssetGLJournal(): Code[20]
    begin
        exit(RecurringFixedAssetGLJournalTok);
    end;

    procedure InsuranceJournal(): Code[20]
    begin
        exit(InsuranceJournalTok);
    end;

    procedure FixedAssetJournal(): Code[20]
    begin
        exit(FixedAssetJournalTok);
    end;

    var
        FixedAssetTok: Label 'FA', MaxLength = 20;
        FixedAssetLbl: Label 'Fixed Asset', MaxLength = 100;
        InsuranceTok: Label 'FA-INS', MaxLength = 20;
        InsuranceLbl: Label 'Insurance', MaxLength = 100;
        FixedAssetGLJournalTok: Label 'FAJNL-GL', MaxLength = 20;
        FixedAssetGLJournalLbl: Label 'Fixed Asset G/L Journal', MaxLength = 100;
        RecurringFixedAssetGLJournalTok: Label 'FAJNL-GLR', MaxLength = 20;
        RecurringFixedAssetGLJournalLbl: Label 'Recurring Fixed Asset G/L Jnl', MaxLength = 100;
        InsuranceJournalTok: Label 'FA-INSJNLG', MaxLength = 20;
        InsuranceJournalLbl: Label 'Insurance Journal', MaxLength = 100;
        FixedAssetJournalTok: Label 'FA-JNL', MaxLength = 20;
        FixedAssetJournalLbl: Label 'Fixed Asset Journal', MaxLength = 100;
}