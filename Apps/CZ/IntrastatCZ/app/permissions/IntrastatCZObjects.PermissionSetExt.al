permissionsetextension 31300 "Intrastat CZ - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit "Data Class. Eval. Handler CZ" = X,
        codeunit "Install Application CZ" = X,
        codeunit IntrastatReportManagementCZ = X,
        codeunit "Intrastat Transformation CZ" = X,
#if not CLEAN22
        codeunit "Sync.Dep.Fld-Customer CZ" = X,
        codeunit "Sync.Dep.Fld-DirectTransLineCZ" = X,
        codeunit "Sync.Dep.Fld-IntDeliveryGr CZ" = X,
        codeunit "Sync.Dep.Fld-ItemCharge CZ" = X,
        codeunit "Sync.Dep.Fld-Item CZ" = X,
        codeunit "Sync.Dep.Fld-Item Jnl. Line CZ" = X,
        codeunit "Sync.Dep.Fld-Job Jnl. Line CZ" = X,
        codeunit "Sync.Dep.Fld-PurchaseHeader CZ" = X,
        codeunit "Sync.Dep.Fld-Purchase Line CZ" = X,
        codeunit "Sync.Dep.Fld-Sales Header CZ" = X,
        codeunit "Sync.Dep.Fld-Sales Line CZ" = X,
        codeunit "Sync.Dep.Fld-Service Header CZ" = X,
        codeunit "Sync.Dep.Fld-Service Line CZ" = X,
        codeunit "Sync.Dep.Fld-ShipmentMethod CZ" = X,
        codeunit "Sync.Dep.Fld-SpecMovement CZ" = X,
        codeunit "Sync.Dep.Fld-StatIndication CZ" = X,
        codeunit "Sync.Dep.Fld-TariffNumber CZ" = X,
        codeunit "Sync.Dep.Fld-Transfer Line CZ" = X,
        codeunit "Sync.Dep.Fld-Vendor CZ" = X,
#endif
        page "Intrastat Delivery Groups CZ" = X,
        page "Specific Movements CZ" = X,
        page "Statistic Indications CZ" = X,
        table "Specific Movement CZ" = X;
}