// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132102 "Customer Exp. Survey Library"
{
    var
        CustomerExpSurveyImpl: Codeunit "Customer Exp. Survey Impl.";

    procedure RemoveUserIdFromMessage(Message: Text): Text
    begin
        exit(CustomerExpSurveyImpl.RemoveUserIdFromMessage(Message));
    end;
}