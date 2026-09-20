namespace WebApi.Interfaz
{
    public interface IEvaluadorInsigniasService
    {
        /// <summary>
        /// Evalua el cumplimiento de requisitos de todas las insignias del usuario
        /// y otorga automaticamente las que aun no tenga y cuyo requisito ya cumple.
        /// Es idempotente: jamás otorga una insignia que el usuario ya posee.
        /// </summary>
        Task<int> EvaluarYOtorgarAsync(int usuarioId);
    }
}
