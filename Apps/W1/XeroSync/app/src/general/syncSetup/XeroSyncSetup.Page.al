Page 2403 "XS Xero Sync Setup"
{
    Caption = 'Xero Synchronization Setup';
    PageType = Card;
    SourceTable = "Sync Setup";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Xero Sync';

    layout
    {
        area(Content)
        {
            group(AccessToken)
            {
                Caption = 'Access Token';

                field("XS Enabled"; "XS Enabled")
                {
                    Caption = 'Enabled';
                    ApplicationArea = Basic, Suite;
                }

                field("Access Key Expiration"; "XS Access Key Expiration")
                {
                    ApplicationArea = Basic, Suite;
                }
            }

            group(Status)
            {
                Visible = SharingEnabled and IsNotInvoicing;
                Caption = 'Sync Status';

                field(SyncStatus; SyncStatus)
                {
                    Caption = 'Sync Task Status';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }

                field(ShowErrorLogsLbl; ShowErrorLogsLbl)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    var
                        JobQueueLogEntry: Record "Job Queue Log Entry";
                        XSJobQueueManagement: Codeunit "XS Job Queue Management";
                    begin
                        XSJobQueueManagement.SetFiltersOnJobQueueLogEntry(JobQueueLogEntry);
                        Page.Run(Page::"Job Queue Log Entries", JobQueueLogEntry);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("XS Set up Xero Synchronization")
            {
                Caption = 'Enable Synchronization';
                ApplicationArea = Basic, Suite;
                Image = Approval;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Page.Run(Page::"XS Xero Synchronization Wizard");
                    UpdateControls();
                end;
            }

            action("XS Stop Synchronization")
            {
                Caption = 'Stop Synchronization';
                ApplicationArea = Basic, Suite;
                Image = Stop;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    StopSynchronization();
                end;
            }

            action("XS Restart Sync")
            {
                Caption = 'Restart Sync Task';
                ApplicationArea = Basic, Suite;
                Image = Restore;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    XSJobQueueManagement: Codeunit "XS Job Queue Management";
                begin
                    XSJobQueueManagement.RestartJobQueueIfStatusError();
                    CurrPage.Update();
                end;
            }

            action("XS SyncNow")
            {
                Caption = 'Sync Now';
                ApplicationArea = Basic, Suite;
                Image = Refresh;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    SyncJob: Codeunit "Sync Job";
                begin
                    SyncJob.RunSyncForeground();
                    Message(SynchronizationDoneTxt);
                end;
            }
            action("XS SyncChange")
            {
                Caption = 'Sync Change';
                ApplicationArea = Invoicing;
                Image = Documents;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = page "XS Sync Change";
            }
            action("XS SyncMapping")
            {
                Caption = 'Sync Mapping';
                ApplicationArea = Invoicing;
                Image = Documents;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = page "XS Sync Mapping";
            }
        }
    }

    var
        SharingEnabled: Boolean;
        SynchronizationDoneTxt: Label 'Synchronization done!';
        SyncStatus: Text;
        ShowErrorLogsLbl: Label 'View Log Entries';
        IsNotInvoicing: Boolean;

    trigger OnOpenPage()
    var
        XeroOAuthManagement: Codeunit "XS OAuth Management";
        EnvInfoProxy: Codeunit "Env. Info Proxy";
        ConsumerKey: Text;
        ConsumerSecret: Text;
    begin
        XeroOAuthManagement.GetConsumerKeyAndSecret(ConsumerKey, ConsumerSecret);
        IsNotInvoicing := not EnvInfoProxy.IsInvoicing();
    end;

    trigger OnAfterGetCurrRecord()
    var
        XsJobQueueManagement: Codeunit "XS Job Queue Management";
    begin
        SharingEnabled := "XS Enabled";
        If "XS Enabled" then
            SyncStatus := XsJobQueueManagement.GetJobQueueStatus();
    end;

    local procedure UpdateControls()
    begin
        GetSingleInstance();
        SharingEnabled := "XS Enabled";
    end;
}

