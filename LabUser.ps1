# Đường dẫn đến file CSV
$csvPath = "C:\Labfile\file.csv"

# Nhập dữ liệu từ file CSV
$users = Import-Csv -Path $csvPath -Header FirstName, LastName, OU, Password

# Đường dẫn OU để di chuyển người dùng
$targetOUPath = "OU=LondonBranch,DC=adatum,DC=com"

# Tạo người dùng trong OU
foreach ($user in $users) {
    # Tạo tên đăng nhập (username) theo định dạng [FirstName].[LastName]
    $username = "$($user.FirstName).$($user.LastName)"
    
    # Đường dẫn OU gốc
    $ouPath = "OU=$($user.OU),DC=adatum,DC=com"

    # Kiểm tra xem tên người dùng đã tồn tại chưa
    if (-not (Get-ADUser -Filter {SamAccountName -eq $username} -ErrorAction SilentlyContinue)) {
        # Tạo người dùng
        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -SamAccountName $username `
                   -UserPrincipalName "$username@adatum.com" `
                   -Path $ouPath `
                   -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
                   -Enabled $true

        Write-Host "Đã tạo người dùng: $username"

        # Di chuyển người dùng vào OU LondonBranch
        $userToMove = Get-ADUser -Filter {SamAccountName -eq $username}
        Move-ADObject -Identity $userToMove -TargetPath $targetOUPath
        Write-Host "Đã di chuyển người dùng $username vào OU LondonBranch"
    } else {
        Write-Host "Người dùng $username đã tồn tại, bỏ qua."
    }
}
