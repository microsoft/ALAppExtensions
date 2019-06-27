// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 138078 "Satisfaction Survey Events"
{
    // [FEATURE] [Satisfaction Survey] [UT]

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        InvoiceTok: Label 'INV', Locked=true;
        FinacialsTok: Label 'FIN', Locked=true;
        TestClientType: ClientType;
        TestAppId: Text;

    [Scope('OnPrem')]
    procedure SetWebClientType()
    begin
        TestClientType := CLIENTTYPE::Web;
    end;

    [Scope('OnPrem')]
    procedure SetPhoneClientType()
    begin
        TestClientType := CLIENTTYPE::Phone;
    end;

    [Scope('OnPrem')]
    procedure SetFinancialsAppId()
    begin
        TestAppId := FinacialsTok;
    end;

    [Scope('OnPrem')]
    procedure SetInvoicingAppId()
    begin
        TestAppId := InvoiceTok;
    end;

    [EventSubscriber(ObjectType::Codeunit, 4030, 'OnAfterGetCurrentClientType', '', false, false)]
    local procedure SetClientOnAfterGetCurrClientType(var CurrClientType: ClientType)
    begin
        CurrClientType := TestClientType;
    end;

    [EventSubscriber(ObjectType::Codeunit, 457, 'OnBeforeGetApplicationIdentifier', '', false, false)]
    local procedure SetAppIdOnBeforeGetApplicationIdentifier(var AppId: Text)
    begin
        AppId := TestAppId;
    end;
}

