using InformationService2API.DTO;
using InformationService2API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using System.Globalization;
using System.Security.Claims;

namespace InformationService2API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EventsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<EventWithLinksDto>>> GetEvents()
        {
            var events = await _context.Events.ToListAsync();
            var result = events.Select(e => MapToDtoWithLinks(e)).ToList();
            return Ok(result);
        }

        [HttpGet("date/{date}")]
        public async Task<ActionResult<IEnumerable<EventWithLinksDto>>> GetEventsByDate(DateTime date)
        {
            var events = await _context.Events
                .Where(e => e.Date.Date == date.Date)
                .ToListAsync();

            var result = events.Select(e => MapToDtoWithLinks(e)).ToList();
            return Ok(result);
        }

        [HttpGet("week/{weekNumber}")]
        public async Task<ActionResult<IEnumerable<EventWithLinksDto>>> GetEventsByWeek(int weekNumber)
        {
            var events = await _context.Events
                .Where(e => CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(
                    e.Date, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday) == weekNumber)
                .ToListAsync();

            var result = events.Select(e => MapToDtoWithLinks(e)).ToList();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EventWithLinksDto>> GetEvent(int id)
        {
            var ev = await _context.Events.FindAsync(id);
            if (ev == null) return NotFound();
            return Ok(MapToDtoWithLinks(ev));
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateEvent(EventDto dto)
        {
            var userId = User.FindFirst("sub")?.Value;

            var newEvent = new Event
            {
                Name = dto.Name,
                Type = dto.Type,
                Date = dto.Date,
                Description = dto.Description,
                UserId = userId
            };

            _context.Events.Add(newEvent);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetEvent), new { id = newEvent.Id }, newEvent);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateEvent(int id, EventDto dto)
        {
            var ev = await _context.Events.FindAsync(id);
            if (ev == null) return NotFound();

            ev.Name = dto.Name;
            ev.Type = dto.Type;
            ev.Date = dto.Date;
            ev.Description = dto.Description;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteEvent(int id)
        {
            var ev = await _context.Events.FindAsync(id);
            if (ev == null) return NotFound();

            _context.Events.Remove(ev);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("report/pdf")]
        public async Task<IActionResult> GetPdfReport()
        {
            var events = await _context.Events
                .OrderBy(e => e.Date)
                .ToListAsync();

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);
                    page.Header().Text("Zestawienie wydarzeń").FontSize(20).Bold().AlignCenter();
                    page.Content().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.ConstantColumn(100);
                        });

                        table.Header(header =>
                        {
                            header.Cell().Text("Nazwa").Bold();
                            header.Cell().Text("Typ").Bold();
                            header.Cell().Text("Data").Bold();
                        });

                        foreach (var ev in events)
                        {
                            table.Cell().Text(ev.Name);
                            table.Cell().Text(ev.Type);
                            table.Cell().Text(ev.Date.ToShortDateString());
                        }
                    });
                    page.Footer().AlignCenter().Text(txt =>
                    {
                        txt.Span("Wygenerowano: ");
                        txt.Span(DateTime.Now.ToString()).Bold();
                    });
                });
            });

            var pdfBytes = document.GeneratePdf();
            return File(pdfBytes, "application/pdf", "zestawienie_eventow.pdf");
        }
        private EventWithLinksDto MapToDtoWithLinks(Event ev)
        {
            var dto = new EventWithLinksDto
            {
                Id = ev.Id,
                Name = ev.Name,
                Type = ev.Type,
                Date = ev.Date,
                Description = ev.Description,
                Links = new List<LinkDto>
        {
            new LinkDto
            {
                Href = Url.Action(nameof(GetEvent), new { id = ev.Id }),
                Rel = "self",
                Method = "GET"
            },
            new LinkDto
            {
                Href = Url.Action(nameof(UpdateEvent), new { id = ev.Id }),
                Rel = "update",
                Method = "PUT"
            },
            new LinkDto
            {
                Href = Url.Action(nameof(DeleteEvent), new { id = ev.Id }),
                Rel = "delete",
                Method = "DELETE"
            }
        }
            };

            return dto;
        }

    }

}
