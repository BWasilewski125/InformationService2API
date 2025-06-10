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
    [Route("api/[controller]")]
    [ApiController]
    public class EventsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EventsController(AppDbContext context)
        {
            _context = context;
        }

        private string GetUserId() =>
            User.FindFirstValue(ClaimTypes.NameIdentifier);

        [HttpGet("day/{date}")]
        public async Task<IActionResult> GetEventsByDay(DateTime date)
        {
            var userId = GetUserId();
            var events = await _context.Events
                .Where(e => e.Date.Date == date.Date && e.UserId == userId)
                .ToListAsync();

            return Ok(events);
        }

        [HttpGet("week/{year}/{weekNumber}")]
        public async Task<IActionResult> GetEventsByWeek(int year, int weekNumber)
        {
            var userId = GetUserId();
            var events = await _context.Events
                .Where(e => e.Year == year && ISOWeek.GetWeekOfYear(e.Date) == weekNumber && e.UserId == userId)
                .ToListAsync();

            return Ok(events);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetEvent(int id)
        {
            var userId = GetUserId();
            var ev = await _context.Events
                .FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);

            if (ev == null)
                return NotFound();

            return Ok(ev);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateEvent([FromBody] EventDto dto)
        {
            var userId = GetUserId();
            var ev = new Event
            {
                Name = dto.Name,
                Type = dto.Type,
                Date = dto.Date,
                Description = dto.Description,
                UserId = userId
            };

            _context.Events.Add(ev);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetEvent), new { id = ev.Id }, ev);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateEvent(int id, [FromBody] EventDto dto)
        {
            var userId = GetUserId();
            var ev = await _context.Events
                .FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);

            if (ev == null)
                return NotFound();

            ev.Name = dto.Name;
            ev.Type = dto.Type;
            ev.Date = dto.Date;
            ev.Description = dto.Description;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("pdf")]
        public async Task<IActionResult> GetEventsPdf()
        {
            var userId = GetUserId();
            var events = await _context.Events
                .Where(e => e.UserId == userId)
                .OrderBy(e => e.Date)
                .ToListAsync();

            var pdf = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);
                    page.Header().Text("Zestawienie wydarzeń").FontSize(20).Bold().AlignCenter();
                    page.Content().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(40); // #
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                        });

                        table.Header(header =>
                        {
                            header.Cell().Text("#").Bold();
                            header.Cell().Text("Nazwa");
                            header.Cell().Text("Typ");
                            header.Cell().Text("Data");
                            header.Cell().Text("Opis");
                        });

                        int index = 1;
                        foreach (var ev in events)
                        {
                            table.Cell().Text(index++.ToString());
                            table.Cell().Text(ev.Name);
                            table.Cell().Text(ev.Type);
                            table.Cell().Text(ev.Date.ToString("yyyy-MM-dd"));
                            table.Cell().Text(ev.Description ?? "-");
                        }
                    });
                });
            }).GeneratePdf();

            return File(pdf, "application/pdf", "events.pdf");
        }
    }
}
