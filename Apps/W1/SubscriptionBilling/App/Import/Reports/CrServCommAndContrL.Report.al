namespace Microsoft.SubscriptionBilling;

report 8002 "Cr. Serv. Comm. And Contr. L."
{
    ApplicationArea = All;
    UsageCategory = None;
    ProcessingOnly = true;
    Caption = 'Create Subscription Lines and Subscription Contract Lines';

    dataset
    {
        dataitem(ImportedServiceCommitmentDataItem; "Imported Subscription Line")
        {
            trigger OnPreDataItem()
            begin
                NoOfRecords := Count;
                Counter := 0;
            end;

            trigger OnAfterGetRecord()
            var
                SkipCreateContractLine: Boolean;
            begin
                if ImportedServiceCommitmentDataItem."Subscription Line created" and ImportedServiceCommitment."Sub. Contract Line created" then
                    CurrReport.Skip();

                Counter += 1;

                if (Counter mod 10 = 0) or (Counter = NoOfRecords) then
                    Window.Update(1, Round(Counter / NoOfRecords * 10000, 1));

                ImportedServiceCommitment := ImportedServiceCommitmentDataItem;
                ImportedServiceCommitment."Error Text" := '';

                if not ImportedServiceCommitmentDataItem."Subscription Line created" then begin
                    ClearLastError();
                    if not Codeunit.Run(Codeunit::"Create Subscription Line", ImportedServiceCommitment) then begin
                        ImportedServiceCommitment."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(ImportedServiceCommitment."Error Text"));
                        ImportedServiceCommitment.Modify(false);
                        SkipCreateContractLine := true;
                    end;
                    Commit(); //retain data even if errors ocurr
                end;

                if (not ImportedServiceCommitment."Sub. Contract Line created") and (not SkipCreateContractLine) then begin
                    ClearLastError();
                    if not Codeunit.Run(Codeunit::"Create Sub. Contract Line", ImportedServiceCommitment) then begin
                        ImportedServiceCommitment."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(ImportedServiceCommitment."Error Text"));
                        ImportedServiceCommitment.Modify(false);
                    end;
                    Commit(); //retain data even if errors ocurr
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostReport()
    begin
        Window.Close();
        Message(ProcessingFinishedMsg);
    end;

    trigger OnPreReport()
    begin
        Window.Open(ImportWindowTxt);
    end;

    var
        ImportedServiceCommitment: Record "Imported Subscription Line";
        Window: Dialog;
        NoOfRecords: Integer;
        Counter: Integer;
        ImportWindowTxt: Label 'Processing Records ...\\@1@@@@@@@@@@@@@@';
        ProcessingFinishedMsg: Label 'Processing finished.';
}