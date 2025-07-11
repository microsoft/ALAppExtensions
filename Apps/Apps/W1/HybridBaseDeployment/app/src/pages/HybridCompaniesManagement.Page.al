namespace Microsoft.DataMigration;

page 4018 "Hybrid Companies Management"
{
    PageType = NavigatePage;
    SourceTable = "Hybrid Company";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Caption = 'Select companies to migrate';
#pragma warning disable AL0254
    SourceTableView = sorting(Replicate) order(descending);
#pragma warning restore AL0254

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                ShowCaption = false;
                field("Replicate"; Rec."Replicate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Replicate';
                    Visible = true;
                    Tooltip = 'Specifies whether to migrate the data from this company.';
                    Width = 5;
                    Editable = true;
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the company.';
                    Visible = true;
                    Editable = false;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the display name of the company.';
                    Visible = true;
                    Editable = false;
                    Width = 10;
                }
                field("Estimated Size"; Rec."Estimated Size")
                {
                    Caption = 'Estimated Size (GB)';
                    ApplicationArea = Basic, Suite;
                    Visible = DisplayDatabaseSize;
                    Editable = false;
                    ToolTip = 'Estimated size in GB of the company data to migrate.';
                }

                field(Replicated; Rec.Replicated)
                {
                    Caption = 'Replicated';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Indicates if the company was replicated already.';
                }
            }

            field(SelectAll; ChooseAll)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Migrate all companies';
                ToolTip = 'Selects all companies in the list.';
                Visible = SelectAllVisible;

                trigger OnValidate();
                begin
                    Rec.SetSelected(ChooseAll);
                    CurrPage.Update(false);
                end;
            }

            field(DeselectAll; ChooseAll)
            {
                ApplicationArea = Basic, Suite;
                Visible = DeselectAllVisible;
                Caption = 'Deselect all companies';
                ToolTip = 'Deselects all companies in the list.';

                trigger OnValidate();
                begin
                    Rec.ModifyAll(Replicate, false);
                    CurrPage.Update(false);
                end;
            }

            group("Instructions")
            {
                ShowCaption = false;
                InstructionalText = 'If you have selected a company that does not exist in Business Central, it will automatically be created for you. This may take a few minutes.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OK)
            {
                ApplicationArea = All;
                Caption = 'OK';
                Image = Approve;
                ToolTip = 'Accept the changes.';
                InFooterBar = true;

                trigger OnAction()
                var
                    HybridCompany: Record "Hybrid Company";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    if not VerifyCompanySelection() then
                        exit;

                    Rec.FindSet();
                    repeat
                        HybridCompany.Get(Rec.Name);
                        HybridCompany.TransferFields(Rec, false);
                        HybridCompany.Modify();
                    until Rec.Next() = 0;
                    CurrPage.Close();

                    HybridCloudManagement.CreateCompanies();
                    Message(UpdatedReplicationCompaniesMsg);
                end;
            }

            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                ToolTip = 'Cancel the changes.';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if Dialog.Confirm(CancelConfirmMsg, false) then
                        CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        HybridCompany: Record "Hybrid Company";
    begin
        SelectAllVisible := HybridCompany.Count() < HybridCompany.GetRecommendedNumberOfCompaniesToReplicateInBatch();
        UpdateDeselectAllVisible();

        if HybridCompany.FindSet() then
            repeat
                Rec := HybridCompany;
                DisplayDatabaseSize := DisplayDatabaseSize or (Rec."Estimated Size" > 0);
                Rec.Insert();
            until HybridCompany.Next() = 0;

        if Rec.FindFirst() then;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateDeselectAllVisible();
    end;

    local procedure UpdateDeselectAllVisible()
    var
        TempHybridCompany: Record "Hybrid Company" temporary;
    begin
        if SelectAllVisible then
            DeselectAllVisible := SelectAllVisible
        else begin
            TempHybridCompany.Copy(Rec);
            Rec.SetRange(Replicate, true);
            DeselectAllVisible := not Rec.IsEmpty();
            Rec.Copy(TempHybridCompany);
        end;
    end;

    var
        ChooseAll: Boolean;
        DisplayDatabaseSize: Boolean;
        SelectAllVisible: Boolean;
        DeselectAllVisible: Boolean;
        NoCompaniesSelectedErr: Label 'You must select at least one company to migrate to continue.';
        UpdatedReplicationCompaniesMsg: Label 'Company selection changes will be reflected on your next migration.';
        CancelConfirmMsg: Label 'Exit without saving company selection changes?';

    local procedure VerifyCompanySelection(): Boolean
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        Rec.Reset();
        Rec.SetRange(Replicate, true);

        if not Rec.FindSet() then
            Error(NoCompaniesSelectedErr);

        if not HybridCloudManagement.CheckMigratedDataSize(Rec) then begin
            Rec.Reset();
            exit(false);
        end;

        Rec.Reset();
        exit(true);
    end;
}
