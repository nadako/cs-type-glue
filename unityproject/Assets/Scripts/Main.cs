using System.Collections.Generic;
using slapi.rambo;
using UniRx;
using UnityEngine;

public class Main : MonoBehaviour
{
	void Awake()
    {
        // можно создавать из C#
		var p = new Player(
            name: "Vasya",
            state: StateId.Idle, // енам-абстракт -> enum
            choice: State.inSquad(10) // чойс -> класс
        );

        // реактив проперти вся хуйня
        p.state.Subscribe(newState => Debug.Log("New state is: " + newState));

        // диспетч из ШЛ дергает реактив проперти \o/
        p.Dispatch(new Stack<string>(new [] {"state"}), "upgrading");

        // toStructure конвертит обратно в анонимный объект стейта
        Debug.Log(p.toStructure());
	}
}
