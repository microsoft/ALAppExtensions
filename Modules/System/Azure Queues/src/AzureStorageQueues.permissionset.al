permissionset 50100 "Azure Queues Permissions"
{
    Assignable = false;
    Permissions =
        tabledata "Azure Queue Setup" = RIMD,
        page "Azure Queue Setup" = X,
        codeunit "Azure Storage Queues Mgt." = X,
        codeunit "Azure Storage Queues Impl." = X;
}