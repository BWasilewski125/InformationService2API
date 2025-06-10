namespace InformationService2API.DTO
{
    public class EventWithLinksDto : EventDto
    {
        public int Id { get; set; }
        public List<LinkDto> Links { get; set; } = new();
    }

    public class LinkDto
    {
        public string Href { get; set; }  
        public string Rel { get; set; }   
        public string Method { get; set; } 
    }
}
