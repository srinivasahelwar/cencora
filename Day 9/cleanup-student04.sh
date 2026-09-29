#!/usr/bin/env bash
set -Eeuo pipefail

EXPECTED_USER="student04@innovatorlearningtrainingso.onmicrosoft.com"
TARGET_RG="rg-student04"

echo "Checking signed-in Azure account..."

CURRENT_USER="$(az account show --query user.name --output tsv)"
SUBSCRIPTION_NAME="$(az account show --query name --output tsv)"
SUBSCRIPTION_ID="$(az account show --query id --output tsv)"

echo "Signed-in user : $CURRENT_USER"
echo "Subscription   : $SUBSCRIPTION_NAME"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Target RG      : $TARGET_RG"

if [[ "${CURRENT_USER,,}" != "${EXPECTED_USER,,}" ]]; then
    echo "ERROR: Expected $EXPECTED_USER but currently signed in as $CURRENT_USER"
    echo "Cleanup stopped."
    exit 1
fi

if [[ "$(az group exists --name "$TARGET_RG")" != "true" ]]; then
    echo "ERROR: Resource Group $TARGET_RG does not exist or is not accessible."
    exit 1
fi

echo
echo "Resources currently present in $TARGET_RG:"
az resource list \
    --resource-group "$TARGET_RG" \
    --query "[].{Name:name, Type:type, Location:location}" \
    --output table

RESOURCE_COUNT="$(az resource list \
    --resource-group "$TARGET_RG" \
    --query "length(@)" \
    --output tsv)"

echo
echo "Total top-level resources found: $RESOURCE_COUNT"

if [[ "$RESOURCE_COUNT" == "0" ]]; then
    echo "Nothing to delete. The Resource Group is already empty."
    exit 0
fi

echo
echo "Checking for deletion locks..."

LOCK_COUNT="$(az lock list \
    --resource-group "$TARGET_RG" \
    --query "length(@)" \
    --output tsv)"

if [[ "$LOCK_COUNT" != "0" ]]; then
    echo "ERROR: Resource locks were found:"
    az lock list \
        --resource-group "$TARGET_RG" \
        --query "[].{Name:name, Level:level, Scope:scope}" \
        --output table

    echo "Cleanup stopped. Ask the trainer/administrator before removing locks."
    exit 1
fi

read -r -p "Type PREVIEW to generate the deletion preview: " PREVIEW_CONFIRMATION

if [[ "$PREVIEW_CONFIRMATION" != "PREVIEW" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

EMPTY_TEMPLATE="$(mktemp)"
trap 'rm -f "$EMPTY_TEMPLATE"' EXIT

printf '%s\n' \
'{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": []
}' > "$EMPTY_TEMPLATE"

echo
echo "Generating what-if preview..."
echo "Resources marked Delete will be removed."

az deployment group what-if \
    --name "cleanup-preview-student04" \
    --resource-group "$TARGET_RG" \
    --mode Complete \
    --template-file "$EMPTY_TEMPLATE"

echo
echo "Review the what-if result carefully."
read -r -p "Type DELETE-STUDENT04 to permanently delete the listed resources: " DELETE_CONFIRMATION

if [[ "$DELETE_CONFIRMATION" != "DELETE-STUDENT04" ]]; then
    echo "Cleanup cancelled. Nothing was deleted."
    exit 0
fi

echo
echo "Deleting resources from $TARGET_RG..."

az deployment group create \
    --name "cleanup-student04" \
    --resource-group "$TARGET_RG" \
    --mode Complete \
    --template-file "$EMPTY_TEMPLATE" \
    --query "properties.provisioningState" \
    --output tsv

echo
echo "Verifying remaining resources..."

az resource list \
    --resource-group "$TARGET_RG" \
    --query "[].{Name:name, Type:type, Location:location}" \
    --output table

REMAINING_COUNT="$(az resource list \
    --resource-group "$TARGET_RG" \
    --query "length(@)" \
    --output tsv)"

if [[ "$REMAINING_COUNT" == "0" ]]; then
    echo "Cleanup completed successfully."
    echo "Resource Group $TARGET_RG was preserved."
else
    echo "Cleanup completed, but $REMAINING_COUNT resource(s) remain."
    echo "Review the list above for dependencies, locks, or permission problems."
fi