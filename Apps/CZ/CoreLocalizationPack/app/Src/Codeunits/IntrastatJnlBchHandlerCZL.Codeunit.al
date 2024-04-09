#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

codeunit 31049 "Intrastat Jnl. Bch Handler CZL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Batch", 'OnBeforeValidateEvent', 'Statistics Period', false, false)]
    local procedure CheckLBatchOnBeforeStatisticsPeriodValidate(var Rec: Record "Intrastat Jnl. Batch"; var xRec: Record "Intrastat Jnl. Batch")
    begin
#pragma warning disable AL0432
        Rec.CheckUniqueDeclarationNoCZL();
        if xRec."Statistics Period" <> '' then
            Rec.CheckJnlLinesExistCZL(Rec.FieldNo("Statistics Period"));
#pragma warning restore AL0432
    end;
}
#endif
