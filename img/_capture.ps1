Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr SetActiveWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int w, int hh, uint f);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
}
'@

function Get-PosWindow {
    $p = Get-Process PosPhPro -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -First 1
    if ($null -eq $p) { throw "PosPhPro process or window not found" }
    return $p.MainWindowHandle
}

function Save-PosWindow([string]$out) {
    $h = Get-PosWindow
    # Restore (9) and maximize (3) — ensures it's not minimized and fills the screen
    [void][Win]::ShowWindow($h, 9)
    Start-Sleep -Milliseconds 200
    [void][Win]::ShowWindow($h, 3)
    Start-Sleep -Milliseconds 300
    # HWND_TOPMOST=-1; flags = SWP_NOMOVE|SWP_NOSIZE = 0x0003
    [void][Win]::SetWindowPos($h, [IntPtr](-1), 0, 0, 0, 0, 0x0003)
    [void][Win]::SetWindowPos($h, [IntPtr](-2), 0, 0, 0, 0, 0x0003)
    [void][Win]::BringWindowToTop($h)
    [void][Win]::SetForegroundWindow($h)
    Start-Sleep -Milliseconds 900
    $r = New-Object Win+RECT
    [void][Win]::GetWindowRect($h, [ref]$r)
    $w  = $r.R - $r.L
    $hg = $r.B - $r.T
    if ($w -le 0 -or $hg -le 0) { throw "Bad rect $w x $hg" }
    $bmp = New-Object System.Drawing.Bitmap $w, $hg
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($r.L, $r.T, 0, 0, (New-Object System.Drawing.Size($w, $hg)))
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Output "saved: $out ($w x $hg)"
}
