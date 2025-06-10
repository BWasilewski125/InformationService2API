using Microsoft.AspNetCore.Identity;

namespace InformationService2API.Models
{
    public class ApplicationUser : IdentityUser
    {
        public ICollection<Event> Events { get; set; }
    }
}
