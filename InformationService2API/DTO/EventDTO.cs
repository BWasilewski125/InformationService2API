using System.ComponentModel.DataAnnotations;

namespace InformationService2API.DTO
{
    public class EventDto
    {
        [Required]
        public string Name { get; set; }

        [Required]
        public string Type { get; set; }

        [Required]
        public DateTime Date { get; set; }

        public string Description { get; set; }
    }

}
