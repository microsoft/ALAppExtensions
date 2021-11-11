page 20100 "AMC Bank Bank Name List"
{
    Caption = 'AMC Banking Bank Name List';
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Page,Setup';
    SourceTable = "AMC Bank Banks";
    UsageCategory = None;
    ContextSensitiveHelpPage = '400';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Bank; Rec.Bank)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the bank, and potentially its country/region code, that supports your setup for import/export of bank data using the AMC Banking feature.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the bank that supports your setup for import/export of bank data using the AMC Banking feature.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Last Update Date"; Rec."Last Update Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the last time the list of supported banks was updated.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(UpdateBankList)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update Bank Name List';
                Image = Restore;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ToolTip = 'Update the bank list with any new banks in your country/region.';

                trigger OnAction()
                var
                    AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
                    FilterNotUsed: Text;
                    ShowErrors: Boolean;
                begin
                    ShowErrors := true;
                    AMCBankImpBankListHndl.GetBankListFromWebService(ShowErrors, FilterNotUsed, LongTimeout, AMCBankingMgt.GetAppCaller());
                end;
            }
        }
    }
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";

    trigger OnInit()
    begin
        ShortTimeout := 5000;
        LongTimeout := 30000;
    end;

    trigger OnOpenPage()
    var
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
        CountryRegionCode: Text;
        HideErrors: Boolean;
    begin
        CountryRegionCode := IdentifyCountryRegionCode(Rec, GetFilter("Country/Region Code"));

        if Rec.IsEmpty() then begin
            AMCBankImpBankListHndl.GetBankListFromWebService(HideErrors, CountryRegionCode, ShortTimeout, AMCBankingMgt.GetAppCaller());
            exit;
        end;

        RefreshBankNamesOlderThanToday(CountryRegionCode, HideErrors, ShortTimeout);
    end;

    var
        LongTimeout: Integer;
        ShortTimeout: Integer;

    local procedure IdentifyCountryRegionCode(var AMCBankBanks: Record "AMC Bank Banks"; "Filter": Text): Text
    var
        CompanyInformation: Record "Company Information";
        BlankFilter: Text;
    begin
        BlankFilter := '''''';

        if Filter = BlankFilter then begin
            CompanyInformation.Get();
            AMCBankBanks.SetFilter("Country/Region Code", CompanyInformation."Country/Region Code");
            exit(AMCBankBanks.GetFilter("Country/Region Code"));
        end;

        exit(Filter);
    end;

    local procedure RefreshBankNamesOlderThanToday(CountryRegionCode: Text; ShowErrors: Boolean; Timeout: Integer)
    var
        AMCBankBanks: Record "AMC Bank Banks";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
    begin
        if CountryRegionCode <> '' then
            AMCBankBanks.SetFilter("Country/Region Code", CountryRegionCode);
        AMCBankBanks.SetFilter("Last Update Date", '<%1', Today());
        if not AMCBankBanks.IsEmpty() then
            AMCBankImpBankListHndl.GetBankListFromWebService(ShowErrors, CountryRegionCode, Timeout, AMCBankingMgt.GetAppCaller());
    end;
}

