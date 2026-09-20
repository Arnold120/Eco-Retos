using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.OpenApi.Models;
using WebApi.Helpers;
using WebApi.Implementacion;
using WebApi.Interfaz;

var builder = WebApplication.CreateBuilder(args);


builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxRequestBodySize = 110L * 1024 * 1024;
});



builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders =
        ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Services.AddControllers();
builder.Services.AddHttpClient();
builder.Services.AddMemoryCache();




var origenesSoporte = builder.Configuration.GetSection("Cors:Origenes").Get<string[]>()
    ?? new[] { "https://eco-retos-soporte.netlify.app", "http://localhost:5173" };
builder.Services.AddCors(options =>
{
    options.AddPolicy("soporte", policy => policy
        .WithOrigins(origenesSoporte)
        .AllowAnyHeader()
        .AllowAnyMethod());
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Eco-Retos API",
        Version = "v1",
        Description = "API para la aplicacion Eco-Retos de educacion ambiental y gamificacion."
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Ingrese el token JWT."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});


builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IRolService, RolService>();
builder.Services.AddScoped<IUsuarioRolService, UsuarioRolService>();
builder.Services.AddScoped<IPerfilService, PerfilService>();
builder.Services.AddScoped<IMonederoService, MonederoService>();
builder.Services.AddScoped<IRecompensaService, RecompensaService>();
builder.Services.AddScoped<IProgresoService, ProgresoService>();
builder.Services.AddScoped<IRachaService, RachaService>();
builder.Services.AddScoped<IJardinService, JardinService>();
builder.Services.AddScoped<IInsigniaService, InsigniaService>();
builder.Services.AddScoped<IUsuarioInsigniaService, UsuarioInsigniaService>();
builder.Services.AddScoped<IRetoService, RetoService>();
builder.Services.AddScoped<IUsuarioRetoService, UsuarioRetoService>();
builder.Services.AddScoped<ITriviaService, TriviaService>();
builder.Services.AddScoped<IPreguntaService, PreguntaService>();
builder.Services.AddScoped<IOpcionRespuestaService, OpcionRespuestaService>();
builder.Services.AddScoped<IIntentoTriviaService, IntentoTriviaService>();
builder.Services.AddScoped<IRespuestaUsuarioService, RespuestaUsuarioService>();
builder.Services.AddScoped<IPublicacionService, PublicacionService>();
builder.Services.AddScoped<IComentarioService, ComentarioService>();
builder.Services.AddScoped<INotificacionService, NotificacionService>();
builder.Services.AddScoped<IReaccionService, ReaccionService>();
builder.Services.AddScoped<ISeguimientoService, SeguimientoService>();
        builder.Services.AddScoped<ICalificacionService, CalificacionService>();
builder.Services.AddScoped<IGuardadoService, GuardadoService>();
builder.Services.AddScoped<IMultimediaService, MultimediaService>();
builder.Services.AddScoped<IMensajeService, MensajeService>();
builder.Services.AddScoped<IDenunciaService, DenunciaService>();
builder.Services.AddScoped<WebApi.Mappers.PublicacionMapper>();
builder.Services.AddScoped<IRecursoService, RecursoService>();
builder.Services.AddScoped<IMaterialService, MaterialService>();
builder.Services.AddScoped<IInventarioService, InventarioService>();
builder.Services.AddScoped<ICompraService, CompraService>();
builder.Services.AddScoped<IDetalleCompraService, DetalleCompraService>();
builder.Services.AddScoped<ICategoriaService, CategoriaService>();
builder.Services.AddScoped<ITokenService, TokenService>();


builder.Services.AddScoped<IAuditoriaService, AuditoriaService>();
builder.Services.AddScoped<IServicioIA, ServicioIA>();
builder.Services.AddScoped<ISoporteService, SoporteService>();


var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("Jwt:Key not configured.");
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "EcoRetos";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "EcoRetosApp";

builder.Services.AddAuthentication(Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(
                System.Text.Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseForwardedHeaders();

app.UseHttpsRedirection();


app.UseCors("soporte");

app.UseStaticFiles();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
