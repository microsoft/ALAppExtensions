// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

report 31200 "Copy User Setup CZL"
{
    Caption = 'Copy User Setup';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FromUserIdField; FromUserId)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'From user';
                        TableRelation = "User Setup";
                        ToolTip = 'Specifies the user name from which will be transfered the setup.';
                    }
                    field(ToUserIdField; ToUserId)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'To User';
                        TableRelation = "User Setup";
                        ToolTip = 'Specifies source and target users';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        UserSetup.LockTable();
        UserSetup.Get(FromUserId);
        UserSetup.CopyToCZL(ToUserId);
    end;

    var
        UserSetup: Record "User Setup";
        FromUserId: Code[50];
        ToUserId: Code[50];

    procedure SetFromUserId(NewFromUserId: Code[50])
    begin
        FromUserId := NewFromUserId;
    end;
}

