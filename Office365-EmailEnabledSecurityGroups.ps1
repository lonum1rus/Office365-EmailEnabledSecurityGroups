# Set Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install the Exchange Online Management module if not already installed
Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber

# Enable TLS 1.2 for secure communication
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Connect to Exchange Online using the V3 module
Connect-ExchangeOnline -Credential $Cred

# Retrieve Email-Enabled Security Groups
$emailEnabledSecurityGroups = Get-DistributionGroup -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "MailUniversalSecurityGroup" }

# Create an array to hold group member information
$groupMembersList = @()

# Iterate through each email-enabled security group to get its members
foreach ($group in $emailEnabledSecurityGroups) {
    $members = Get-DistributionGroupMember -Identity $group.Identity | Select-Object DisplayName, PrimarySmtpAddress, Alias
    foreach ($member in $members) {
        $groupMembersList += [PSCustomObject]@{
            GroupName = $group.DisplayName
            GroupEmail = $group.PrimarySmtpAddress
            MemberName = $member.DisplayName
            MemberEmail = $member.PrimarySmtpAddress
            MemberAlias = $member.Alias
        }
    }
}

# Display the retrieved group members
$groupMembersList | Format-Table GroupName, GroupEmail, MemberName, MemberEmail, MemberAlias -AutoSize

# Export the group members to a CSV file
$groupMembersList | Export-Csv -Path "C:\Temp\EmailEnabledSecurityGroups_Members.csv" -NoTypeInformation