namespace WebApp.Services;
public static class FileHelper
{
    static readonly string[] AllowedExtensions = { ".png", ".jpg", ".jpeg", ".webp", ".gif" };
    const long MaxSize = 5 * 1024 * 1024;

    public static async Task<string?> SaveAsync(IFormFile file, string folder, IWebHostEnvironment env)
    {
        string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (file.Length == 0 || file.Length > MaxSize || !AllowedExtensions.Contains(ext)) return null;
        string dir = Path.Combine(env.WebRootPath, folder);
        Directory.CreateDirectory(dir);
        string name = Guid.NewGuid().ToString("N") + ext;
        using FileStream stream = new FileStream(Path.Combine(dir, name), FileMode.Create);
        await file.CopyToAsync(stream);
        return name;
    }
    public static void Delete(string? fileName, string folder, IWebHostEnvironment env)
    {
        if (string.IsNullOrEmpty(fileName)) return;
        string path = Path.Combine(env.WebRootPath, folder, Path.GetFileName(fileName));
        if (File.Exists(path)) File.Delete(path);
    }
}