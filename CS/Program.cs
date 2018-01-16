using System;
using System.Collections.Generic;
using slapi.rambo;

class Program
{
    static void Main(string[] args)
    {
        var gameData = new GameData(
            heroId: new HeroId(10),
            items: new GameData_items_element[0],
            level: 15,
            name: "Hi",
            ready: true,
            someItems: new Dictionary<SomeKey, Some>(),
            state: StateId.Building,
            state2: GameData_state2.inProgress(0.5));


        var o = gameData.state2.Match(
            done: result => 1,
            inProgress: progress => progress,
            c: v => 1 + 3
        );

        Console.WriteLine(gameData.toStructure().ToString());
        Console.ReadKey();
    }
}
