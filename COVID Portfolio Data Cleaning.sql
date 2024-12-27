

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
    FROM 
        [dbo].[CovidDeaths] dea
    JOIN 
        [dbo].[CovidVaccinations] vac
        ON dea.location = vac.location
        AND dea.date = vac.date
where dea.continent is not null